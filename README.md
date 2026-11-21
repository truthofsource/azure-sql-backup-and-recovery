# Azure SQL Backup & Point-in-Time Recovery

[![Azure SQL backup and PITR — illustrated overview](docs/diagrams/architecture.png)](docs/diagrams/architecture.svg)

[View SVG](docs/diagrams/architecture.svg) · [Download PNG](docs/diagrams/architecture.png) · [Edit in draw.io](docs/diagrams/architecture.drawio)

**Prepare to restore the database without putting the current records at risk.**

[The problem](#the-business-problem) · [The solution](#the-solution) · [What was built](#what-was-built) · [Proof it works](#proof-it-works) · [Commands](docs/COMMANDS.md) · [Step by step](#step-by-step)

## The Business Problem

Employee profiles, onboarding progress, timesheets and payroll-related records depend on the application database. An accidental update, deletion or service incident can affect several business processes at once. Recovery needs an agreed point in time and a safe destination before anyone changes the live database.

The records also refer to uploaded files and encrypted values. Restoring database rows from one time while using missing documents or unavailable key versions can leave an apparently restored system unable to support actual work. Backup retention settings describe available protection, but they do not prove that the operator can connect to and validate a restored database.

The business need was a clearly scoped database-recovery procedure that protects the current system, identifies related dependencies and distinguishes prepared restore checks from tests that have actually been completed.

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

## Tools Used and What They Do

| Tool or service | What it does | Where it fits |
| --- | --- | --- |
| Azure SQL Database backup/restore features | Provide supported database recovery methods and retained points. | Actual service capability; a new hosted restore was not executed for this project. |
| Azure CLI | Inspect supported recovery metadata and operation status. | Operating utility; the local checker has no cloud restore adapter. |
| T-SQL queries | Check schema, migration history, safe aggregates and effective permissions. | Selected validation queries; not a complete business acceptance suite. |
| Microsoft Entra ID and contained SQL users | Control which identity can connect and execute database operations. | Actual access layers; administrative reads do not prove runtime grants. |
| Azure Key Vault and Blob Storage | Supply encryption-key and file dependencies needed by the recovered application. | Separate recovery dependencies, not restored merely by SQL PITR. |
| Python and Terraform | Check fictional recovery plans and selected infrastructure defaults. | Local/reference validation; not measured production RTO or restore completion. |

Point-in-time restore, database copy and geo-restore are different operations. The manual-only GitHub workflow does not submit any of them.

## Step by Step

A real point-in-time recovery of your own Azure SQL test database into a separate database, verified using a known marker.

[Open the standalone build guide](docs/BUILD-YOUR-OWN.md) or follow the same complete instructions below.

Start with a new folder, your own files and your own accounts. The numbered steps below describe the build; no portfolio repository checkout is required. The existing implementation/evidence elsewhere in this repository is a separate reference, not a claim that your new build has already passed.

### Prerequisites

Azure subscription; permission to create a logical SQL server/database and restore it; an approved SQL client with Entra database access and a permitted network path. Source and restored databases are billed separately.

Use Bash on Linux/macOS/WSL for Bash blocks and PowerShell for PowerShell blocks. Select the tool versions supported by the official sources below, record the versions you actually install and retain generated dependency locks. Cloud resources, scanner downloads, logs and external AI calls can create costs; review the stated scope before enabling them.

### Create your project folder

Choose a new folder name. These first commands create a blank project; an optional `git init` gives it its own history. Create parent directories in your editor when a later step introduces a nested file.

```bash
mkdir my-azure-sql-backup-and-recovery
cd my-azure-sql-backup-and-recovery
git init
```

Create `.gitignore` before saving credentials or build outputs:

```gitignore
.venv/
node_modules/
.env
.env.*
local.settings.json
credentials.json
token.json
*.pem
*.key
*.tfstate*
*.tfplan
.terraform/
private*/
captures/
backups/
batch.json
reports/
out/
app-config.local.yaml
```

The source/file snippets are a starting implementation you type or paste into the named files. Replace `YOUR_*`, names, regions and addresses only with values from your own lab; do not place real client/employee records in a test project. Keep your terminal in this project root unless a step explicitly changes directory.

Before a first commit, set your own repository-local author with `git config user.name "YOUR_NAME"` and `git config user.email "YOUR_PUBLIC_COMMIT_EMAIL"`. Review `git status --short` and the staged diff before publishing; ignored local files are not a substitute for reviewing what you upload.

### Step 1 — Create a dedicated SQL lab

**Where:** Azure Portal → SQL databases → Create.

Create a small test database and a new logical server in your lab group, set its Microsoft Entra administrator, and select the backup redundancy/retention you intend to test. Configure only your approved client path; do not enable broad Azure-service access as a shortcut.

**Check before continuing:** Your identity can connect to this database and the selected backup settings are recorded.

### Step 2 — Write the recovery marker

**Where:** Your approved SQL query editor connected to the source database.

Create the table below, insert a harmless value and record the server UTC time after the insert commits. This time must later fall inside the actual restorable window.

```sql
CREATE TABLE dbo.RecoveryProbe (
  Id int NOT NULL PRIMARY KEY,
  Marker nvarchar(80) NOT NULL
);
INSERT INTO dbo.RecoveryProbe (Id, Marker) VALUES (1, N'before-change');
SELECT SYSUTCDATETIME() AS MarkerCommittedUtc;
SELECT * FROM dbo.RecoveryProbe;
```

**Check before continuing:** The source returns before-change and a recorded UTC timestamp.

### Step 3 — Make a later, distinguishable change

**Where:** The same source connection.

After recording the committed marker time, change the row to after-change and record another UTC time. Wait until the portal offers a restore time after the first commit but before this second commit; do not assume a newly created database already has usable backups.

```sql
UPDATE dbo.RecoveryProbe SET Marker = N'after-change' WHERE Id = 1;
SELECT SYSUTCDATETIME() AS LaterChangeUtc;
```

**Check before continuing:** The source now says after-change and you have a valid time separating the two states.

### Step 4 — Restore into a new database

**Where:** Source database → Restore → Point-in-time.

Choose your recorded, available UTC restore time and a new name such as my-recovery-check. Keep the source database intact; Azure SQL restore creates another database rather than overwriting the existing one.

**Check before continuing:** The restore operation finishes and the new database becomes available.

### Step 5 — Verify the recovered data

**Where:** A new SQL connection explicitly targeting my-recovery-check.

Confirm the database name before querying the marker. Expect before-change in the restored database and after-change in the source; also check the intended identity/network access because data recovery alone does not prove application recovery.

```sql
SELECT DB_NAME() AS ConnectedDatabase;
SELECT Id, Marker FROM dbo.RecoveryProbe WHERE Id = 1;
```

**Check before continuing:** Your own two-query comparison demonstrates the selected recovery point.

### Step 6 — Record recovery time and clean up

**Where:** Your run record and Azure Portal.

Save the requested UTC time, restore start/end, observed marker and unresolved access/dependency work. Delete only the dedicated restored/source lab databases and server after reviewing backup retention and any retained charges.

**Check before continuing:** Your evidence distinguishes service availability, data correctness and application readiness.

### Verification and your own screenshots

| Evidence | What to record | Your result |
| --- | --- | --- |
| New build | Your own files/resource settings and tool versions | Not yet recorded |
| Working path | The actual successful request, configuration or recovery result | Not yet recorded |
| Failure boundary | A meaningful denied, malformed, stale or failed case | Not yet recorded |
| Recovery / cleanup | What you restored or removed and what remains billed | Not yet recorded |

Capture your own architecture/configuration, one working result and one failure/recovery result. Keep tokens, credentials, personal records and private identifiers out of public screenshots. The architecture diagram explains the design; record your own results rather than treating it as execution evidence.

### Troubleshooting order

1. Confirm the named file, working directory and selected tool/interpreter.
2. Check the exact input and resource/account selected for the failing step.
3. Separate identity permission, network/DNS reachability and application validation.
4. Keep the actual error and reconcile an unknown write outcome before repeating it; do not widen access or repeat paid operations blindly.

The numbered steps describe a build procedure. Local syntax checks, an accepted API request, a completed hosted operation and a human verification are different evidence levels; fill in the verification table with what you actually observed.

### Official implementation references

- [learn.microsoft.com — recovery-using-backups?view=azuresql](https://learn.microsoft.com/en-us/azure/azure-sql/database/recovery-using-backups?view=azuresql)

<details>
<summary>Reference: how the existing platform implementation operates</summary>

A short walkthrough of the process, with technical instructions and evidence limits in the sections below.

1. **Review backup coverage (Azure SQL metadata)** — Confirm the database backup retention and the time range available for recovery. Keep live and test environment settings distinct.

2. **Choose a separate destination** — Identify the intended recovery time and an isolated restore target. Check ownership, network access and related files or keys before proceeding.

3. **Run the readiness checks (Python readiness checker)** — The local checker tests the proposed recovery details using fictional inputs. It does not submit an Azure restore or replace the live database.

4. **Plan the final verification** — The prepared rehearsal calls for checking restored records, access and application compatibility. That live restore rehearsal has not been completed in this case study.

</details>

## Architecture

[View the illustrated project overview](docs/diagrams/architecture.svg).

Geo backup storage is not a running secondary database or automatic application failover. This project adds no custom SQL backup worker, BACPAC schedule or Azure Backup vault.

## What Was Built

| Component | Role in plain words | Implementation |
| --- | --- | --- |
| Actual SQL Terraform module | Defines server/database, retention, private DNS/link and endpoint | [Module](infra/modules/sql/) |
| Explicit environment profiles | Preserve production S0/Geo/14 versus Basic/Local/seven-day defaults | [Root](infra/main.tf) |
| Original prepared SQL contract | Record the required preparation and test conditions without claiming a restore was performed | [Contract](reference/sql-rehearsal-contract.json) |
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

The desktop/mobile local program remains available to run; proper Azure screenshots are deferred. Green checks describe fictional readiness guards, not successful Azure restores. [Dated validation](docs/VALIDATION.md) records exact counts and limits.

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

## Troubleshooting Lessons

A production review action exposed a missing column grant, and a wider check found other runtime write gaps. The repair used exact grants and application-identity probes, illustrating why a correct schema alone does not establish a usable database. [Read the incident, evidence and verification](docs/LESSONS-LEARNED.md).

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
