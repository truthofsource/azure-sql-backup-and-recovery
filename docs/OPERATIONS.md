# Operations and troubleshooting

| Symptom | Investigate | Safe response |
| --- | --- | --- |
| Desired point is unavailable | Actual earliest window, database age/deletion state, selected recovery method | Select only service-supported history; retention configuration is not a receipt |
| SQL metadata is readable but connection fails | Different management/data identities, DNS, private route, TLS and contained permissions | Diagnose each layer; do not open public SQL to bypass it |
| Recovery target already exists | Prior operation, uncertain outcome or wrong target name | Reconcile status privately; do not overwrite/retry blindly |
| Geo backups confused with failover | Backup redundancy versus an online replica | Use the correct recovery method and reviewed cutover plan |
| Recovered encrypted values fail | Wrapped-key version, AAD/schema or identity access missing | Restore the matching application encryption dependencies |
| Files missing or inaccessible | Blob bytes/metadata, owner, revision and scan-proof mismatch | Reconcile exact records and byte identity; do not bypass quarantine |
| Restored workload starts sending work | Contained identities or app/worker bindings were not isolated | Contain the recovery target; preserve source and external-event evidence |

Record safe operation IDs, stages, counts and timings privately. Do not log row values, connection strings or credentials. Refresh the complete schema ledger before acceptance; a maximum migration number alone does not prove identical migration history. The example aggregate SQL is intentionally limited.

No routine key rotation or application redeployment recreates a missing SQL restore point. Database recovery, application rollback, key recovery and external side-effect reconciliation are different operations.
