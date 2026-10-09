# Send Side Quota Enforcement in One Time Password Software: research artifact

Reproducibility artifact **v5.1-r18** for *Send Side Quota Enforcement in One Time Password
Software: A Package Survey and a Measurement Under Concurrency* by Naveed Ahmad (Prince Sultan
University). The manuscript (v5.1) is under review at Computers & Security; it is not an accepted
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
| `otp_quota_artifact_v5.1-r18.zip` | The complete artifact (code, records, models, paper source, review logs). SHA-256 `2e054b6d010b32fa1030c0afafb8c60916dd603ea585c3ff44a1107339ca79b5` |
| `notebooks/otp_quota_reproduction.ipynb` | The reproduction notebook, without outputs |
| `notebooks/otp_quota_reproduction_executed.ipynb` | The same notebook, executed against v5.1-r18 |
| `CITATION.cff` | Citation record (GitHub shows it as "Cite this repository") |

Earlier versions (v4.7-r15, v4.8-r16, v5.0-r17) remain available from the repository history.

```bash
sha256sum otp_quota_artifact_v5.1-r18.zip
unzip otp_quota_artifact_v5.1-r18.zip && cd otp_quota_artifact_v5.1-r18
python3 study/manifest.py verify      # every file against MANIFEST.sha256.json
python3 regenerate.py                 # recompute results/paper_numbers.json from the records
python3 study/manifest.py verify      # the regenerated files must match byte for byte
```

## What is inside the archive

| Path | Contents |
|---|---|
| `svc/` | The service 2.2.1 with eight admission designs (`app.py` SQLite, `app_pg.py` PostgreSQL), opt in switches (`opt.py`), an independent provider process (`provider.py`), the library apps (`libs/`), and the sites of the executed packages (`pkgs/`); 2.0.0, 2.1.0 and 2.2.0 in `archive/` |
| `study/` | Survey pipeline, experiment drivers (`run_round7.py`, `run_packages7.py`, `run_libraries.py`), the policy oracle, and the generators of every table, figure, and number macro of the paper |
| `results/` | Every record: `r4/` main study, `r5/` checks, `r6/` libraries, `r7/` round 7 and round 8 arms (one record per delivery of the executed packages, one per request of the load arm, the lock wait arm, the datastores' clock semantics) and the survey validation and corrections; `paper_numbers.json` |
| `formal/` | TLA+ models (untimed and timed) checked with TLC, Tamarin models (fixed and parameterized limit), runners, verdicts, traces (`formal/README.md`) |
| `paper/` | LaTeX source of manuscript v5.0 (`otp_cose.tex`, `cose/`), the compiled PDF, and the Word converter |
| `review/` | Reviewer reports, the response letter, the literature search record, and the second coder kit (`coding_kit/`) |

## Main results (manuscript v5.0)

**Survey.** Of the 42 packages that the search discovers and that were read by hand, 10 carry a
send side check in their own code; 4 of those constrain, per recipient, an attacker who only
requests codes, and 1 more does so only within one worker process. Every filter stage misses
relevant packages (detector recall within the candidates about 55%), so these are counts of a
cohort, not prevalence estimates.

**Concurrency.** Declared limit 3 per number per window. The three designs that check and then
write exceeded it in 113 to 120 of 120 simultaneous trials with k > 3 on SQLite (up to 10.7 times);
no design whose grant is one atomic operation violated it in a burst, in 1,620 more trials over
three independent runs per datastore either. An independent provider process agreed with the grant
records in every trial. A sequential test passed every design.

**Executed packages** (round 8 rerun, every delivery an archived record). django-mfa 4.6.0 delivered up
to 27 codes against its limit of 3; django-otp 1.7.3 up to 14 against its cooldown of 1; django-otp-auth 2.3.0 delivered every
simultaneous request (per process state); fastapi-otp-auth 0.1.4, whose decision is one atomic
Redis increment, never exceeded its limit; django-two-factor-auth and django-otp-twilio delivered
every request.

**Time, faults, and lock waits.** With requests delayed across a window boundary, the conditional
update on the request's clock exceeded the limit by authorization instant in 16 of 30 trials; its
variant on the datastore's clock (service 2.2.1, which reads the clock under the lock that
serializes grants) in none. In the deterministic lock wait arm, every design that reads its clock
before that lock attributed the waiting grants to the window before the boundary and reached 6
grants with authorization instant in one window; the 2.2.1 designs attributed them correctly on both
datastores. The reservation release rule of service 2.1.0 overspent (up to 7 billed
in one window against 3); releasing only certain failures, only on the reserved row, on the
datastore's clock, did not.

**Formal.** 342 timed TLC runs (including the billing bound by authorization instant, which only
the reservation on the datastore's clock keeps) and Tamarin proofs (any number of requests; limits 1 to 5, and any
limit in the parameterized model) agree with the measurements and identify the release rules that
violate the billing bound.

**Libraries.** Every configuration whose counter is shared by all workers and increments
atomically held the limit (Redis fixed, moving, sliding; Memcached); per process stores failed with
four workers and held with one; django-ratelimit's database cache, which its own check rejects,
failed.

These are local measurements against a provider stub, not real bills or a general failure rate.

## Scope and responsible use

No real SMS is sent and no external service, maintainer, or recipient is contacted. The package
behaviors recorded here are send side races or per process state, not verification bypasses; as
of October 9, 2026 the maintainers had not been notified, and the author will report them through
each project's security contact. Do not run these tests against systems you are not authorized to
test.

## Citation

```bibtex
@misc{ahmad2026otpartifact,
  author       = {Ahmad, Naveed},
  title        = {Send Side Quota Enforcement in One Time Password Software:
                  A Package Survey and a Measurement Under Concurrency (research artifact)},
  year         = {2026},
  version      = {v5.1-r18},
  howpublished = {\url{https://github.com/nahmedpsu/otp-send-side-quota-artifact}}
}
```

## License

MIT for the code. The package metadata in `results/` was collected from the public package index
and remains subject to the licenses of the projects it describes.
