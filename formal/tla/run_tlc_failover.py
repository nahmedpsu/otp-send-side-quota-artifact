"""Run TLC on AdmissionTimedFailover.tla: the timed model with a replicated
store (a primary and one replica) and at most one failover per run, for the
three counter row designs, under asynchronous and synchronous replication.
Round 10.

Each run checks one property. Runs are breadth first on four workers; a
violated run is repeated on one worker, so that the counterexample kept in
traces_failover/ is a shortest one. Three runs with F = 0 come first and must
reproduce the verdict, and where the run holds the distinct state count, of
the same run of the timed model (results_timed.json).

Output, beside this script: results_failover.jsonl (one line per finished
run, written as the suite goes, so an interrupted invocation resumes),
results_failover.json, results_failover.md, results_failover_meta.json, and
traces_failover/.

    python3 formal/tla/run_tlc_failover.py [path/to/tla2tools.jar]
"""
import datetime
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
JAR = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("TLA2TOOLS", "tla2tools.jar")
WORKERS = os.environ.get("TLC_WORKERS", "4")
HEAP = os.environ.get("TLC_HEAP", "8g")
BASE = dict(W=2, T=4, K=1, faults=False, D=None, F=1)
NL = [(2, 1), (3, 1), (3, 2)]
NL_RES = [(2, 1), (3, 1)]

runs = []


def add(group, design, prop, sync, **kw):
    for N, L in kw.pop("nl", NL):
        runs.append(dict(BASE, group=group, design=design, prop=prop, sync=sync, N=N, L=L, **kw))


# H0. F = 0: the extension must reproduce the timed model (one run per design;
#     two of them hold in the timed model, one is violated)
runs.append(dict(BASE, group="H0", design="ConditionalUpdate", prop="C1tau", sync=False, N=3, L=1, F=0))
runs.append(dict(BASE, group="H0", design="ConditionalUpdateDb", prop="C1", sync=False, N=3, L=2, F=0))
runs.append(dict(BASE, group="H0", design="ReserveBeforeSendDb", prop="C2", sync=False, N=3, L=1, F=0, faults=True))
# H. one failover, asynchronous and synchronous replication
for sync in (False, True):
    for d in ("ConditionalUpdate", "ConditionalUpdateDb"):
        for p in ("C1", "C1F", "C1tau", "C1tauF"):
            add("H", d, p, sync)
    for p in ("C1", "C1F", "C1tau", "C1tauF", "C2", "C2F", "NonNegative"):
        add("H", "ReserveBeforeSendDb", p, sync, faults=True, nl=NL_RES)

# the reservation's runs are the largest: keep them last within each replication mode
SIZE = {"ConditionalUpdate": 0, "ConditionalUpdateDb": 1, "ReserveBeforeSendDb": 2}
runs[3:] = sorted(runs[3:], key=lambda r: (r["sync"], SIZE[r["design"]], r["N"] * 10 + r["L"], r["prop"]))

TIMED = {}
_t = os.path.join(HERE, "results_timed.json")
if os.path.exists(_t):
    TIMED = {r["name"]: r for r in json.load(open(_t))}


def timed_name(r):
    g = "A" if r["design"] == "ConditionalUpdate" else "G"
    return f"{g}_{r['design']}_N{r['N']}_L{r['L']}_T{r['T']}_{r['prop']}" + ("_faults" if r["faults"] else "")


def name(r):
    v = [r["group"], r["design"], f"N{r['N']}", f"L{r['L']}", f"T{r['T']}", r["prop"]]
    if r["faults"]:
        v.append("faults")
    v.append(f"F{r['F']}")
    v.append("sync" if r["sync"] else "async")
    return "_".join(v)


TLC_VERSION = None


def tlc(r, cfg, workers, meta):
    global TLC_VERSION
    cmd = ["java", f"-Xmx{HEAP}", "-XX:+UseParallelGC", "-cp", JAR, "tlc2.TLC", "-noGenerateSpecTE",
           "-nowarning", "-config", cfg, "-workers", str(workers), "-metadir", meta, "-cleanup",
           "AdmissionTimedFailover.tla"]
    p = subprocess.run(cmd, cwd=HERE, capture_output=True, text=True)
    shutil.rmtree(meta, ignore_errors=True)
    out = p.stdout
    v = re.search(r"TLC2 Version [^\n]*", out)
    if v and not TLC_VERSION:
        TLC_VERSION = v.group(0).strip()
    m = re.findall(r"(\d+) states generated, (\d+) distinct states found", out)
    distinct = int(m[-1][1]) if m else None
    if "No error has been found" in out:
        v = "holds"
    elif re.search(r"Invariant .* is violated|Temporal properties were violated", out):
        v = "violated"
    else:
        raise SystemExit(f"TLC did not finish {os.path.basename(cfg)} (exit {p.returncode}):\n{out[-4000:]}\n{p.stderr[-2000:]}")
    return v, distinct, out


def run(r):
    nm = name(r)
    cfg = os.path.join(HERE, "cfg_failover", nm + ".cfg")
    os.makedirs(os.path.dirname(cfg), exist_ok=True)
    kind = "PROPERTY" if r["prop"] == "Termination" else "INVARIANT"
    open(cfg, "w").write(
        f"SPECIFICATION Spec\n"
        f"CONSTANTS N = {r['N']}\n          L = {r['L']}\n          W = {r['W']}\n"
        f"          T = {r['T']}\n          K = {r['K']}\n          Design = \"{r['design']}\"\n"
        f"          Faults = {str(r['faults']).upper()}\n"
        f"          D = {r['T'] if r['D'] is None else r['D']}\n"
        f"          F = {r['F']}\n          Sync = {str(r['sync']).upper()}\n"
        f"{kind} {r['prop']}\n")
    t0 = datetime.datetime.now(datetime.timezone.utc)
    v, distinct, out = tlc(r, cfg, WORKERS, os.path.join(HERE, "states_failover", nm))
    res = dict(r, name=nm, verdict=v, distinct=distinct, workers=int(WORKERS))
    if v == "violated":
        # repeat on one worker: breadth first on one worker gives a shortest counterexample
        v1, d1, out1 = tlc(r, cfg, 1, os.path.join(HERE, "states_failover", nm + "_w1"))
        res["distinct_1worker"] = d1
        res["trace_states"] = len(re.findall(r"^State \d+:", out1, re.M))
        tdir = os.path.join(HERE, "traces_failover")
        os.makedirs(tdir, exist_ok=True)
        key = f"{r['design']}_{r['prop']}" + ("_faults" if r["faults"] else "") + f"_F{r['F']}_" + ("sync" if r["sync"] else "async")
        path = os.path.join(tdir, key + ".txt")
        if not os.path.exists(path):
            open(path, "w").write(out1)
    res["seconds"] = round((datetime.datetime.now(datetime.timezone.utc) - t0).total_seconds(), 1)
    if r["group"] == "H0":
        tr = TIMED.get(timed_name(r))
        res["timed_run"] = timed_name(r)
        res["timed_verdict"] = tr["verdict"] if tr else None
        res["timed_distinct"] = tr["distinct"] if tr else None
        res["reproduces_verdict"] = bool(tr) and tr["verdict"] == v
        res["reproduces_states"] = bool(tr) and v == "holds" and tr["distinct"] == distinct
    return res


if __name__ == "__main__":
    jsonl = os.path.join(HERE, "results_failover.jsonl")
    done = {}
    if os.path.exists(jsonl):
        for line in open(jsonl):
            if line.strip():
                d = json.loads(line)
                done[d["name"]] = d
    if not done:
        shutil.rmtree(os.path.join(HERE, "traces_failover"), ignore_errors=True)
    shutil.rmtree(os.path.join(HERE, "cfg_failover"), ignore_errors=True)
    results = []
    for i, r in enumerate(runs, 1):
        nm = name(r)
        if nm in done:
            res = done[nm]
            results.append(res)
            print(f"[{i}/{len(runs)}] {nm}: {res['verdict']} ({res['distinct']} states) [resumed]", flush=True)
            continue
        res = run(r)
        results.append(res)
        with open(jsonl, "a") as fh:
            fh.write(json.dumps(res) + "\n")
        extra = ""
        if r["group"] == "H0":
            extra = f" timed: {res['timed_verdict']} ({res['timed_distinct']}) reproduces verdict={res['reproduces_verdict']} states={res['reproduces_states']}"
        print(f"[{i}/{len(runs)}] {nm}: {res['verdict']} ({res['distinct']} states, {res['seconds']}s)"
              + (f" trace {res['trace_states']} states" if res['verdict'] == 'violated' else "") + extra, flush=True)
    shutil.rmtree(os.path.join(HERE, "cfg_failover"), ignore_errors=True)
    shutil.rmtree(os.path.join(HERE, "states_failover"), ignore_errors=True)
    json.dump(results, open(os.path.join(HERE, "results_failover.json"), "w"), indent=1)
    meta = dict(date=datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds"),
                tlc_version=TLC_VERSION,
                tla2tools_sha256=hashlib.sha256(open(JAR, "rb").read()).hexdigest(),
                workers=int(WORKERS), heap=HEAP, cores=os.cpu_count(), runs=len(results),
                largest_distinct=max((x["distinct"] or 0) for x in results))
    json.dump(meta, open(os.path.join(HERE, "results_failover_meta.json"), "w"), indent=1)
    with open(os.path.join(HERE, "results_failover.md"), "w") as f:
        f.write("| group | design | N | L | T | faults | F | replication | property | verdict | distinct states | trace states | seconds |\n")
        f.write("|" + "---|" * 13 + "\n")
        for r in results:
            f.write(f"| {r['group']} | {r['design']} | {r['N']} | {r['L']} | {r['T']} | {r['faults']} | {r['F']} | "
                    f"{'synchronous' if r['sync'] else 'asynchronous'} | {r['prop']} | {r['verdict']} | {r['distinct']} | "
                    f"{r.get('trace_states', '')} | {r.get('seconds', '')} |\n")
    print("wrote", len(results), "runs; largest", meta["largest_distinct"], "distinct states")
