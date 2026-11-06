# Azure SQL Backup & Point-in-Time Recovery

**Prepare to restore the database without putting the current records at risk.**

[The problem](#the-business-problem) · [The solution](#the-solution) · [What was built](#what-was-built) · [Proof it works](#proof-it-works) · [Commands](docs/COMMANDS.md)

![Working SQL recovery readiness reference](docs/images/01-overview.png)

## The Business Problem

The application keeps employee, onboarding, timesheet and payroll records in Azure SQL. A mistake or outage needs a recovery plan that protects the original database and includes the files and encryption keys connected to those records. Backup settings alone do not prove a restore will work.

## The Solution

Make the database’s backup and retention settings explicit. Identify the recovery time and destination, prepare a separate restore environment, and check the private connection and related files and keys. Keep the difference between a planned restore and a completed restore test visible.

**Business outcome:** Make database recovery easier to prepare and review without overstating what has actually been restored and tested.

### Actual platform implementation

- The [SQL module](infra/modules/sql/main.tf) is actual implementation source with neutral resource labels and no private identifiers.
- The production caller supplies **Standard S0, Geo backup storage and 14-day point-in-time retention**. Nonproduction keeps the module's Basic/Local/seven-day defaults.
- The logical server has public network access Off, Entra-only administration, managed identity and TLS 1.2; private DNS/VNet linkage and a SQL private endpoint provide its selected private path.
- An October 4 module-ownership migration recorded six no-op address moves and a zero-change post-plan. It did not change the existing backup policy or restore data.
- The later SQL restore contract is **prepared, not executed**. Its historical schema-181 expectation must be refreshed before a future drill.

The local readiness program is newly authored reference code based on that procedure. It validates fictional inputs and submits no Azure operation. Source configuration, dated acceptance, tests using simulated cloud responses and a real restore are separate evidence. [Source map](docs/SOURCE-MAP.md) · [Acceptance matrix](docs/ACCEPTANCE.md).

## Architecture

```mermaid
flowchart LR
  App[Authorized application] --> Private[Private endpoint + DNS]
  Entra[Entra identity] --> SQL[(Azure SQL S0)]
  Private --> SQL
  SQL --> Native[Azure-managed full / differential / log backups]
  Native --> Retain[14-day PITR + Geo backup redundancy]
  Retain -. separately authorized recovery .-> Target[New owned recovery database]
  Target --> Review[Contained permissions / schema / safe aggregates]
  Keys[Matching field-encryption key versions] --> Review
  Files[Matching Blob bytes and ownership] --> Review
  Review --> Decision[Reviewed recovery or cleanup; no automatic cutover]
```

Geo backup storage is not a running secondary database or automatic application failover. This project adds no custom SQL backup worker, BACPAC schedule or Azure Backup vault.

## What Was Built

| Component | Role in plain words | Implementation |
| --- | --- | --- |
| Actual SQL Terraform module | Defines server/database, retention, private DNS/link and endpoint | [Module](infra/modules/sql/) |
| Explicit environment profiles | Preserve production S0/Geo/14 versus Basic/Local/seven-day defaults | [Root](infra/main.tf) |
| Original prepared SQL contract | Preserves readiness holds and acceptance without claiming an executed drill | [Contract](reference/sql-rehearsal-contract.json) |
| Local readiness checker | Reject wrong source, existing/unowned target, invalid point and incomplete isolation | [Code](lab/readiness.py) |
| Positive and negative tests | Exercise preparation boundaries without SQL credentials or provider access | [Tests](tests/test_readiness.py) |
| Read-only validation query | Gather schema/catalog/principal aggregates only on an owned target | [SQL](queries/isolated-restore-validation.sql) |

## Proof It Works

**Local validation:** 16 readiness tests, seven demo assertions and three Terraform tests using simulated cloud responses passed. No cloud restore or resource operation.

### 1. Infrastructure preserves the production policy and private boundary

```bash
terraform -chdir=infra init -backend=false -input=false
terraform -chdir=infra validate
terraform -chdir=infra/modules/sql init -backend=false -input=false
terraform -chdir=infra/modules/sql test
```

**Look for:** three mock-plan tests verify production overrides, separate nonproduction defaults, Entra-only/private SQL and the SQL DNS/endpoint binding. They do not create a server or prove a live network route. [Terraform guide](infra/README.md).

### 2. Unsafe preparation requests fail locally

```bash
python -B -m unittest discover -s tests -v
python -B -m lab demo
```

**Look for:** wrong-source, source-overwrite, existing-target, future/too-old point, unsupported method/server and missing-isolation cases are rejected. The successful result says **prepared-not-submitted**, with `productionAuthorization=false` and zero Azure operations. It is not a restored database.

### 3. Evidence is visible and reproducible

![Executed local preparation assertions](docs/images/02-validation.png)

Desktop/mobile screenshots are captured from this working program. Green checks describe fictional readiness guards, not successful Azure restores. [Dated validation](docs/VALIDATION.md) records exact counts and limits.

## Run It Locally

Python 3.12; standard library only:

```bash
python -m venv .venv
source .venv/bin/activate
python -B -m unittest discover -s tests -v
python -B -m lab demo
python -B -m lab serve --port 8011
```

PowerShell: invoke `.venv\Scripts\python.exe` directly instead of activating. Open [the loopback workbench](http://127.0.0.1:8011), run the demonstration and inspect Validation/Evidence. Stop with Ctrl+C. No Azure login, actual database or paid request is needed.

## Backup and Restore Process

Azure SQL owns its automatic backup schedule. Our Terraform controls selected retention and backup redundancy; it does not run a cron script to export the database.

For a real recovery: inspect the available backup window, select the correct method/point, review the exact owned target and private/custodian access, restore, validate database and external dependencies, measure time/loss window, then make a separate cutover or cleanup decision. [Step-by-step procedure](docs/RESTORE-REHEARSAL.md).

The documented standard CLI PITR path creates another database on the source logical server. A dedicated-server recovery design needs an explicitly supported method or additional stage; do not assume `az sql db restore` accepts the copy command's `--dest-server` option. The local checker intentionally supports only its stated same-server preparation mode.

## Security Practices

- Keep restore targets separate and do not update live application connection bindings.
- Review contained users and permissions; a new database name alone does not isolate restored identities.
- SQL recovery still needs matching Blob metadata/bytes and application field-encryption key versions.
- A database's TDE protection and the application's Key Vault field-encryption wrapper are distinct layers.
- Terraform `prevent_destroy` is a source guard, not a cloud-wide denial of every administrator's delete operation.
- Real resource IDs, database contents, tokens, connection strings and Terraform state stay out of this repository.

## Scaling and Tradeoffs

Fourteen-day retention is a time window, not a guaranteed RPO or restore duration. Larger databases, transaction replay, target compute, private networking and dependencies affect recovery. Geo backups and longer retention add storage/transfer considerations. [Strengths, weaknesses and tradeoffs](docs/SCALING.md).

## Project Guides

| Guide | Purpose |
| --- | --- |
| [Architecture](docs/ARCHITECTURE.md) | SQL, backup, private access and external dependency boundaries |
| [Native backups](docs/NATIVE-BACKUPS.md) | PITR, geo-restore, LTR and BACPAC distinctions |
| [Restore rehearsal](docs/RESTORE-REHEARSAL.md) | Method selection, isolation, acceptance and cleanup |
| [Command reference](docs/COMMANDS.md) | Local checks and optional read-only cloud inspection examples |
| [Source map](docs/SOURCE-MAP.md) | Actual module versus newly authored reference code |
| [Acceptance](docs/ACCEPTANCE.md) | Completed ownership work versus unexecuted restore |
| [Operations](docs/OPERATIONS.md) | Diagnose window, identity, DNS and dependency failures |
| [Scaling](docs/SCALING.md) | RPO/RTO, capacity, retention and tradeoffs |
| [Capture plan](docs/SCREENSHOT-PLAN.md) | Future nonproduction Portal/terminal evidence |

## Cost and Cleanup

No service is started or changed for this public project. Applying Terraform creates billable SQL/network resources; no apply workflow is supplied. The real module's deletion guard makes cleanup an explicit reviewed operation. The GitHub workflow is manual-only and has no Azure deployment credentials. [Security and publication boundary](SECURITY.md).
