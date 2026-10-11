# Send Side Quota Enforcement in One Time Password Software: research artifact

Reproducibility artifact **v5.2-r19** for *Send Side Quota Enforcement in One Time Password
Software: A Package Survey and a Measurement Under Concurrency* by Naveed Ahmad (Prince Sultan
University). The manuscript (v5.2) is under review at Computers & Security; it is not an accepted
or published article.

Services that send one time passwords by SMS pay for every message. This artifact holds one
operational contract for the bound on sending (C1 send bound, C2 billing bound under faults, C3 no
duplicate call, C4 availability), a survey of 42 Python code delivery packages with a validation
of every filter stage, a measurement of eight admission designs under simultaneous requests, six
surveyed packages executed on their own delivery paths, timed and untimed formal models, and a
benchmark of two rate limiting libraries in 13 configurations, together with every raw record and
the script that regenerates every reported number from those records.

## Files in this repository

| File | What it is |
|---|---|
| `otp_quota_artifact_v5.2-r19.zip` | The complete artifact (code, records, models, paper source, review logs). SHA-256 `8727a104e740b02d3bd99417053cde0937772699851ba7e9bb787c9793631a59` |
| `notebooks/otp_quota_reproduction.ipynb` | The reproduction notebook, without outputs |
| `notebooks/otp_quota_reproduction_executed.ipynb` | The same notebook, executed against v5.2-r19 |
| `CITATION.cff` | Citation record (GitHub shows it as "Cite this repository") |

Earlier versions (v4.7-r15, v4.8-r16, v5.0-r17, v5.1-r18) remain available from the repository history.

```bash
sha256sum otp_quota_artifact_v5.2-r19.zip
unzip otp_quota_artifact_v5.2-r19.zip && cd otp_quota_artifact_v5.2-r19
python3 study/manifest.py verify      # every file against MANIFEST.sha256.json
python3 regenerate.py                 # recompute results/paper_numbers.json from the records
python3 study/manifest.py verify      # the regenerated files must match byte for byte
```

## What v5.2-r19 adds (round 9)

- **Service 2.2.2**: the granting statement of the two datastore clock designs returns the clock
  reading it used, so every grant's record carries the authorization instant itself (`tau_db`)
  beside the issue and return instants that bound it; 2.2.1 is archived and runnable.
- **Lock wait arm and the time arm's datastore clock rows rerun on 2.2.2** (`results/r7/lockwait_*_r9.*`,
  `timing_*_db222.*`); the round 8 records stay in the archive and are reported under their own
  prefixes. Every verdict by authorization instant is decided over the whole issue to return
  interval of each grant (violated under every placement of the instants, under some, or neither)
  and reported as definitive or ambiguous; for the 2.2.2 designs the verdict by the recorded
  instant is reported beside it.
- **Load arm rerun with one record per number from the server's datastore**
  (`results/r7/load_*.server.jsonl`), so that a request the client saw fail is reconciled with the
  provider calls the server recorded; the round 8 run on a larger host is archived as
  `load_*_r8.*`.
- The manuscript's Algorithm 2 shows the corrected procedure, the lock wait arm names its
  instants, the sequential conclusion is restricted to configurations with a declared bound, and
  the two time bases are named in every verdict.

## What is inside the archive

| Path | Contents |
|---|---|
| `svc/` | The service 2.2.2 with eight admission designs (`app.py` SQLite, `app_pg.py` PostgreSQL), opt in switches (`opt.py`), an independent provider process (`provider.py`), the library apps (`libs/`), and the sites of the executed packages (`pkgs/`); 2.0.0, 2.1.0, 2.2.0 and 2.2.1 in `archive/` |
| `study/` | Survey pipeline, experiment drivers (`run_round7.py`, `run_packages7.py`, `run_libraries.py`), the policy oracle, and the generators of every table, figure, and number macro of the paper |
| `results/` | Every record: `r4/` main study, `r5/` checks, `r6/` libraries, `r7/` rounds 7 to 9 (one record per delivery of the executed packages, one per request and one per number of the load arm, the lock wait arm with recorded authorization instants, the datastores' clock semantics) and the survey validation and corrections; `paper_numbers.json` |
| `formal/` | TLA+ models (untimed and timed) checked with TLC, Tamarin models (fixed and parameterized limit), runners, verdicts, traces (`formal/README.md`) |
| `paper/` | LaTeX source of manuscript v5.2 (`otp_cose.tex`, `cose/`), the compiled PDF, and the Word converter |
| `review/` | Reviewer reports, the response letters, the literature search record, and the second coder kit (`coding_kit/`) |

## Main results (manuscript v5.2)

**Survey.** Of the 42 packages that the search discovers and that were read by hand, 10 carry a
send side check in their own code; 4 of those constrain, per recipient, an attacker who only
requests codes, and 1 more does so only within one worker process. Every filter stage misses
relevant packages (detector recall within the candidates about 55%), so these are counts of a
cohort, not prevalence estimates. The blinded second coding is not yet complete; all labels are one
coder's.

**Concurrency.** Declared limit 3 per number per window. The three designs that check and then
write exceeded it in 113 to 120 of 120 simultaneous trials with k > 3 on SQLite (up to 10.7 times);
no design whose grant is one atomic operation violated it in a burst, in 1,620 more trials over
three independent runs per datastore either. An independent provider process agreed with the grant
records in every trial. Requests sent one at a time stayed within the declared limit of every design
and of every package that declares one.

**Executed packages** (round 8, every delivery an archived record). django-mfa 4.6.0 delivered up
to 27 codes against its limit of 3; django-otp 1.7.3 up to 14 against its cooldown of 1;
django-otp-auth 2.3.0 delivered every simultaneous request (per process state); fastapi-otp-auth
0.1.4, whose decision is one atomic Redis increment, never exceeded its limit; django-two-factor-auth
and django-otp-twilio, which declare no send bound, delivered every request, sequential or not.

**Time, faults, and lock waits.** With requests delayed across a window boundary, the conditional
update on the request's clock exceeded the limit by authorization instant in 16 of 30 trials under
every placement of the instants in their intervals; its variant on the datastore's clock in none,
by the intervals and by the recorded instant. In the deterministic lock wait arm (service 2.2.2),
every design that reads its clock before the serializing lock attributed the waiting grants to the
window before the boundary and reached 6 grants with authorization instant in one window; the
datastore clock designs read the clock after the lock, recorded it, and held the limit in every
trial on both datastores. The reservation release rule of service 2.1.0 overspent (up to 7 billed
in one window against 3); releasing only certain failures, only on the reserved row, on the
datastore's clock, did not.

**Formal.** 342 timed TLC runs (including the billing bound by authorization instant, which only
the reservation on the datastore's clock keeps) and Tamarin proofs (any number of requests; limits
1 to 5, and any limit in the parameterized model) agree with the measurements and identify the
release rules that violate the billing bound.

**Libraries.** Every configuration whose counter is shared by all workers and increments
atomically held the limit (Redis fixed, moving, sliding; Memcached); per process stores failed with
four workers and held with one; django-ratelimit's database cache, which its own check rejects,
failed.

These are local measurements against a provider stub, not real bills or a general failure rate.

## Scope and responsible use

No real SMS is sent and no external service, maintainer, or recipient is contacted. The package
behaviors recorded here are send side races or per process state, not verification bypasses; as
of October 11, 2026 the maintainers had not been notified, and the author will report them through
each project's security contact. Do not run these tests against systems you are not authorized to
test.

## Citation

```bibtex
@misc{ahmad2026otpartifact,
  author       = {Ahmad, Naveed},
  title        = {Send Side Quota Enforcement in One Time Password Software:
                  A Package Survey and a Measurement Under Concurrency (research artifact)},
  year         = {2026},
  version      = {v5.2-r19},
  howpublished = {\url{https://github.com/nahmedpsu/otp-send-side-quota-artifact}}
}
```

## License

MIT for the code. The package metadata in `results/` was collected from the public package index
and remains subject to the licenses of the projects it describes.
