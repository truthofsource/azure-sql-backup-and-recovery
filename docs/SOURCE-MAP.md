# Actual source and public adaptations

| Public path | Source relationship |
| --- | --- |
| infra/modules/sql/main.tf | Actual SQL module; neutral logical labels/administrator display name only |
| infra/modules/sql/variables.tf | Actual variables including Basic/Local/seven-day defaults |
| infra/modules/sql/outputs.tf | Actual outputs with matching neutral labels |
| infra/modules/sql/versions.tf | Actual provider compatibility declaration |
| reference/sql-rehearsal-contract.json | Extracted SQL portion of the original prepared rehearsal; neutral source/prefix; original status and dated schema expectation retained |
| infra/main.tf | New standalone wrapper expressing actual production/nonproduction policy choices; capacity/names are public inputs |
| lab/readiness.py, lab/domain.py, tests/ | Newly authored offline reference based on the procedure, not deployed automation |
| queries/isolated-restore-validation.sql | New read-only reference using the platform ledger/catalog pattern; not a complete executed acceptance |

[Machine provenance](source-map.json) records private-source file hashes without copying private Git history or identifiers. The original full production root, raw migration plans, database/state contents and cloud receipts are excluded.

The accepted October module ownership change is historical evidence. It is not an instruction to replay moved blocks or replace state today. [Acceptance matrix](ACCEPTANCE.md).
