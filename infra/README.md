# Actual SQL module and explicit backup profiles

`modules/sql` comes from the implemented platform module. Logical resource labels and administrator display name are neutral; actual resource behavior and defaults are retained. It defines six resources: data resource group, SQL logical server, database, private DNS zone, VNet link and private endpoint.

The wrapper root is a standalone public adaptation of the production/nonproduction callers. Production selects S0, Geo and 14-day STR; nonproduction selects Basic, Local and seven days. The public production capacity default of 10 GiB is a reference input, not a claim about live database size. Supply reviewed unique names and an existing network/subnet before any separate apply.

```bash
terraform -chdir=infra init -backend=false -input=false
terraform -chdir=infra fmt -check -recursive
terraform -chdir=infra validate
terraform -chdir=infra/modules/sql init -backend=false -input=false
terraform -chdir=infra/modules/sql test
```

The three tests live in the extracted module and use mock providers. Tests do not run against the subscription or prove private DNS, Entra membership or data-plane connectivity. The ordinary root has no backend configured. Real Terraform state/plans and inputs must remain private.

The module does not declare LTR, a failover group, active geo-replication, SQL audit routing or a custom backup schedule. Production-specific auditing remains outside the extracted module. Backup Geo and database zone redundancy are different controls; the selected source has database zone_redundant=false.

The SQL private endpoint is part of the established SQL implementation. It is not permission to activate unrelated deferred endpoints elsewhere. No cloud create/restore/destroy is performed by validation. `prevent_destroy` is retained; do not remove it just to make a demo apply/destroy convenient.
