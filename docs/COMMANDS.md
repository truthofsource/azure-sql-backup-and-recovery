# Commands and expected results

## Local preparation checks — no Azure

Python 3.12, from the project root:

```bash
python -m venv .venv
source .venv/bin/activate
python -B -m unittest discover -s tests -v
python -B -m lab demo
python -B -m lab serve --port 8011
```

PowerShell without changing execution policy:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -B -m unittest discover -s tests -v
.\.venv\Scripts\python.exe -B -m lab demo
.\.venv\Scripts\python.exe -B -m lab serve --port 8011
```

Expected: sixteen tests and seven demonstration checks; the result is prepared-not-submitted with no production authorization. Open the loopback viewer on port 8011; Ctrl+C stops it. These are new public reference tests, not extracted historical SQL restore tests.

## Terraform — no apply

```bash
terraform -chdir=infra init -backend=false -input=false
terraform -chdir=infra fmt -check -recursive
terraform -chdir=infra validate
terraform -chdir=infra/modules/sql init -backend=false -input=false
terraform -chdir=infra/modules/sql test
```

Expected: schema validation and three module mock-plan checks. Provider installation needs access to its registry or a previously verified cache; no real credentials are used by the tests.

## Optional read-only Azure inspection — not run for this project

Use an authorized account, explicit subscription and the intended source. Keep real IDs and output private.

```bash
az account show --query "{subscription:name,tenant:tenantId}" -o json
az sql db show --subscription "<subscription>" --resource-group "<source-group>" --server "<source-server>" --name "<source-db>" -o json
az sql db str-policy show --subscription "<subscription>" --resource-group "<source-group>" --server "<source-server>" --name "<source-db>" -o json
az sql db ltr-policy show --subscription "<subscription>" --resource-group "<source-group>" --server "<source-server>" --name "<source-db>" -o json
az sql server show --subscription "<subscription>" --resource-group "<source-group>" --name "<source-server>" -o json
```

Look for actual retention, backup redundancy, earliestRestoreDate, current status and server public-network setting. No configured LTR policy is not the same as proof that no old LTR backup exists. Resource metadata reads do not prove a SQL data connection or a recoverable point.

The local snapshot's fields are a teaching contract, not a direct Azure CLI response schema. A real adapter must validate and map actual response fields rather than pasting an arbitrary JSON response into the checker.
