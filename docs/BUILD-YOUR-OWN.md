# Build your own from scratch: Azure Sql Backup And Recovery

A real point-in-time recovery of your own Azure SQL test database into a separate database, verified using a known marker.

Start with a new folder, your own files and your own accounts. The numbered steps below describe the build; no portfolio repository checkout is required. The existing implementation/evidence elsewhere in this repository is a separate reference, not a claim that your new build has already passed.

## Prerequisites

Azure subscription; permission to create a logical SQL server/database and restore it; an approved SQL client with Entra database access and a permitted network path. Source and restored databases are billed separately.

Use Bash on Linux/macOS/WSL for Bash blocks and PowerShell for PowerShell blocks. Select the tool versions supported by the official sources below, record the versions you actually install and retain generated dependency locks. Cloud resources, scanner downloads, logs and external AI calls can create costs; review the stated scope before enabling them.

## Create your project folder

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

## Step 1 — Create a dedicated SQL lab

**Where:** Azure Portal → SQL databases → Create.

Create a small test database and a new logical server in your lab group, set its Microsoft Entra administrator, and select the backup redundancy/retention you intend to test. Configure only your approved client path; do not enable broad Azure-service access as a shortcut.

**Check before continuing:** Your identity can connect to this database and the selected backup settings are recorded.

## Step 2 — Write the recovery marker

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

## Step 3 — Make a later, distinguishable change

**Where:** The same source connection.

After recording the committed marker time, change the row to after-change and record another UTC time. Wait until the portal offers a restore time after the first commit but before this second commit; do not assume a newly created database already has usable backups.

```sql
UPDATE dbo.RecoveryProbe SET Marker = N'after-change' WHERE Id = 1;
SELECT SYSUTCDATETIME() AS LaterChangeUtc;
```

**Check before continuing:** The source now says after-change and you have a valid time separating the two states.

## Step 4 — Restore into a new database

**Where:** Source database → Restore → Point-in-time.

Choose your recorded, available UTC restore time and a new name such as my-recovery-check. Keep the source database intact; Azure SQL restore creates another database rather than overwriting the existing one.

**Check before continuing:** The restore operation finishes and the new database becomes available.

## Step 5 — Verify the recovered data

**Where:** A new SQL connection explicitly targeting my-recovery-check.

Confirm the database name before querying the marker. Expect before-change in the restored database and after-change in the source; also check the intended identity/network access because data recovery alone does not prove application recovery.

```sql
SELECT DB_NAME() AS ConnectedDatabase;
SELECT Id, Marker FROM dbo.RecoveryProbe WHERE Id = 1;
```

**Check before continuing:** Your own two-query comparison demonstrates the selected recovery point.

## Step 6 — Record recovery time and clean up

**Where:** Your run record and Azure Portal.

Save the requested UTC time, restore start/end, observed marker and unresolved access/dependency work. Delete only the dedicated restored/source lab databases and server after reviewing backup retention and any retained charges.

**Check before continuing:** Your evidence distinguishes service availability, data correctness and application readiness.

## Verification and your own screenshots

| Evidence | What to record | Your result |
| --- | --- | --- |
| New build | Your own files/resource settings and tool versions | Not yet recorded |
| Working path | The actual successful request, configuration or recovery result | Not yet recorded |
| Failure boundary | A meaningful denied, malformed, stale or failed case | Not yet recorded |
| Recovery / cleanup | What you restored or removed and what remains billed | Not yet recorded |

Capture your own architecture/configuration, one working result and one failure/recovery result. Keep tokens, credentials, personal records and private identifiers out of public screenshots. Existing portfolio images are references, not evidence that you performed these steps.

## Troubleshooting order

1. Confirm the named file, working directory and selected tool/interpreter.
2. Check the exact input and resource/account selected for the failing step.
3. Separate identity permission, network/DNS reachability and application validation.
4. Keep the actual error and reconcile an unknown write outcome before repeating it; do not widen access or repeat paid operations blindly.

The numbered steps describe a build procedure. Local syntax checks, an accepted API request, a completed hosted operation and a human verification are different evidence levels; fill in the verification table with what you actually observed.

## Official implementation references

- [learn.microsoft.com — recovery-using-backups?view=azuresql](https://learn.microsoft.com/en-us/azure/azure-sql/database/recovery-using-backups?view=azuresql)

The walkthrough layout follows the prerequisites → creation/configuration → test → verification → troubleshooting → cleanup pattern of the [Splunk project reference](https://github.com/davidharris6/splunk-siem-log-analysis). Its Splunk-specific settings are not copied into unrelated projects.
