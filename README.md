# Send-side OTP quota enforcement: research artifact

Reproducibility materials for **Send-Side Quota Enforcement in One-Time-Password Software: A Package Survey and a Measurement Under Concurrency**, by Naveed Ahmad. This is a prepublication research artifact; the manuscript has not been represented here as an accepted or published IEEE Access article.

The study surveys OTP delivery packages and measures six quota-enforcement patterns under concurrent requests. It reports admissions against declared limits, not real SMS charges. Experiments use a local provider stub and do not contact a production OTP provider or send messages to recipients.

## Results at a glance

**Package survey.** The artifact contains a manually reviewed sample of 42 Python packages and records whether sending controls were enforced, delegated, or absent. This is a sample, not an ecosystem prevalence estimate. Its classification audit is retained in the complete archive.

**Concurrency measurement.** The declared limit was three admissions per number per window. The table shows *median / maximum admissions* across 30 trials per cell in the round-4 SQLite main sweep. `k` is the number of simultaneous requests; values above three in one policy window violate the declared bound.

| Quota implementation | k = 8 | k = 32 | Policy-violating trials across all k (of 180) |
| --- | ---: | ---: | ---: |
| Count then insert | 8 / 8 | 6.5 / 27 | 113 |
| Read, modify, write counter | 8 / 8 | 18.5 / 32 | 118 |
| Increment after send | 8 / 8 | 32 / 32 | 120 |
| Conditional atomic update | 3 / 3 | 3 / 3 | 0 |
| Guarded write transaction | 3 / 3 | 3 / 3 | 0 |
| Reserve before send | 3 / 3 | 3 / 3 | 0 |

The archived request events and `artifact/regenerate.py` independently derive the policy classifications; `artifact/results/paper_numbers.md` includes PostgreSQL, boundary, worker, and latency arms. Across all round-4 arms, the three one-step patterns had 0 policy violations in 2,430 trials. These are local measurements of the experimental implementations under the stated workload.

**Interpretation.** A request count can exceed a per-window bound legitimately when an arm crosses a window boundary. The artifact evaluates the admission event in its recorded policy window rather than treating every total above the limit as a violation. These measurements describe the tested software and workload; they do not measure real customer bills or establish a general failure rate for deployed OTP services.

## Artifact download and map

Download [`otp-send-side-quota-artifact-ready.zip`](otp-send-side-quota-artifact-ready.zip) for the complete, versioned artifact. The paths below are inside the ZIP's top-level folder. The repository landing page highlights selected findings; the archive is the source of record for files and checksums.

| Path | Contents |
| --- | --- |
| `artifact/README.md` | Full methodology, results, limitations, and reproduction instructions |
| `artifact/notebooks/otp_quota_reproduction_executed.ipynb` | Executed notebook and playbook |
| `artifact/svc/` | Versioned OTP service and archived source used for the reported runs |
| `artifact/study/` | Experiment drivers, survey scripts, policy oracle, event analysis, and tests |
| `artifact/results/` | Raw trial and request records, survey audit, and derived outputs |
| `artifact/paper/` | Manuscript source and preview PDF |
| `artifact/review/` | Review trackers, rebuttals, and verification logs |

The archive preserves the supplied **v3.4-r6 snapshot** with its own `MANIFEST.sha256.json`. Run artifact commands from its `artifact/` directory so repository metadata above it does not affect verification.

## Quick verification

```bash
unzip otp-send-side-quota-artifact-ready.zip
cd otp-send-side-quota-artifact/artifact
python3 study/manifest.py verify
python3 study/test_manifest.py
python3 regenerate.py
python3 study/manifest.py verify
```

The first check validates the supplied files. The second runs nine verifier tests. Regeneration recomputes the derived numbers from archived event records and the frozen package audit; the final check requires byte-identical derived outputs. Install the environment and run the complete suite using `artifact/README.md` inside the archive. A full rerun writes to `artifact/results/repro/` without overwriting the shipped trials.

The notebook reruns the SQLite main sweep and examines archived analyses. It does **not** independently rerun every arm or recollect the package survey. For the complete protocol, use `artifact/reproduce.sh` and the survey commands in the artifact README.

## Scope

The package survey is a sample of one language ecosystem; its end-to-end recall is unknown. The concurrency study uses one host, two datastores, local traffic, and a provider stub. It does not establish the exposure or bill of any deployed application. The review history and prepublication manuscript are included for auditability, not as evidence of journal acceptance.

The artifact also includes a package-execution experiment. Coordinate disclosure of any version-specific third-party finding with the maintainers. Do not direct tests at third-party systems without authorization.

## Citation and license

Cite this as a **research artifact, version v3.4-r6** until a final publication record exists; see `CITATION.cff` inside the archive. Code is MIT licensed under its `LICENSE`. Package metadata and third-party dependencies retain their respective licenses.
