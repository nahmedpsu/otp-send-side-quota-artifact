# Round 10: the timed model under replication and failover

This folder carries the round 10 addition to the formal models of the artifact
(`formal/` inside `otp_quota_artifact_v5.2-r19.zip` holds the untimed model,
the timed model, and the Tamarin theories; its `README.md` describes them). The
manuscript *An Atomic Grant Is Not Enough* cites the files here by these paths.

| File | What it is |
|---|---|
| `tla/AdmissionTimedFailover.tla` | The timed model (`AdmissionTimed.tla` of the archive) with a replicated store: a primary and one replica, a `Replicate` action that copies the primary's row to the replica at any moment, and a `Failover` action, at most `F` times per run, that promotes the replica so that every acknowledged write it has not received is lost. `Sync = TRUE` is synchronous replication (a failover loses nothing). The extension covers the three designs whose grant is one statement on a counter row: the conditional update on the request's clock, the conditional update on the datastore's clock, and the reservation on the datastore's clock. |
| `tla/run_tlc_failover.py` | Runs the 79-run suite below and writes the result files. |
| `tla/results_failover.json`, `.md`, `.jsonl` | One record per run: design, bounds, replication mode, property, verdict, distinct states, length of the counterexample, and wall time. The `.jsonl` is written as the suite runs, so an interrupted invocation resumes. |
| `tla/results_failover_meta.json` | TLC version, SHA-256 of `tla2tools.jar`, workers, heap, date. |
| `tla/traces_failover/` | The first counterexample of each (design, property, replication mode), found on one worker, so it is a shortest one. |
| `tla/results_timed.json` | Copy of the timed model's results from the archive, read by the runner for the `F = 0` check. |
| `formal_round10.log` | The log of the invocation that produced the files above. |

## The suite (79 runs)

* `H0`, three runs with `F = 0`, one per design: the extension must reproduce
  the verdict of the same run of the timed model, and, where the run holds,
  its distinct state count. `Replicate` is enabled only while a failover can
  still happen, so with `F = 0` the state space is the timed model's.
* `H`, 76 runs with `F = 1`, `W = 2` ticks, `T = 4`, one store, no bound on the
  grant to call delay, under asynchronous and synchronous replication:
  * conditional update on the request's clock, and on the datastore's clock:
    `C1`, `C1F`, `C1tau`, `C1tauF` at `(N, L) in {(2, 1), (3, 1), (3, 2)}`;
  * reservation on the datastore's clock, with provider faults: `C1`, `C1F`,
    `C1tau`, `C1tauF`, `C2`, `C2F`, `NonNegative` at `(N, L) in {(2, 1), (3, 1)}`.

  `C1F`, `C1tauF`, `C2F` are the weaker bounds of `(F + 1) * L` grants or billed
  calls per window.

Every run is breadth first on four workers; a violated run is repeated on one
worker and that counterexample is the one kept. An `UPDATE` on a row that a
failover removed changes nothing, as in SQL: `Roll2`, `Inc` and `Release` are
guarded by `row.present`, and the one statement of the datastore clock designs
begins with `INSERT OR IGNORE`, so it recreates the row.

## Running

```bash
# Java 11 or later and tla2tools.jar (v1.8.0 release asset)
#   https://github.com/tlaplus/tlaplus/releases/download/v1.8.0/tla2tools.jar
python3 formal/tla/run_tlc_failover.py /path/to/tla2tools.jar    # TLC_WORKERS and TLC_HEAP override 4 and 8g
```

## Results of the invocation of October 24, 2026

79 runs; the largest visited 92 341 641 distinct states (the reservation on the datastore's clock, `C2F`, N = 3, L = 1, asynchronous). The three `F = 0` runs reproduce the timed model's verdict (3 of 3) and, for the two that hold, its distinct state count (2 of 2). Wall time about 21 minutes on four cores.

| Design | Replication | C1 | C1, (F+1)L | C1 by tau | C1 by tau, (F+1)L | C2 | C2, (F+1)L | Count >= 0 |
|---|---|---|---|---|---|---|---|---|
| Conditional atomic update (request's clock) | asynchronous | violated | holds | violated | violated at 3/1 |  |  |  |
| Conditional atomic update (request's clock) | synchronous | holds | holds | violated | violated at 3/1 |  |  |  |
| Conditional update, datastore clock | asynchronous | violated | holds | violated | holds |  |  |  |
| Conditional update, datastore clock | synchronous | holds | holds | holds | holds |  |  |  |
| Reserve, datastore clock (faults) | asynchronous | violated | violated at 3/1 | violated | violated at 3/1 | violated | holds | violated |
| Reserve, datastore clock (faults) | synchronous | violated | violated at 3/1 | violated | violated at 3/1 | holds | holds | holds |

`violated`: a counterexample at every bound checked; `violated at N/L`: only at those bounds. The reservation's send bound columns are checked and reported in `results_failover.md`; under provider faults C1 fails by design, since a failed call still consumed a grant.

The shortest counterexample for the conditional update on the datastore's clock under one asynchronous failover has 6 states (`traces_failover/ConditionalUpdateDb_C1_F1_async.txt`): the first request is granted and the primary's row records it, the replica has not received it, the failover promotes the replica, the store has no counter row, and the second request is granted against that empty state.
