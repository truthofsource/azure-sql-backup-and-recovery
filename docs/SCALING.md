# Scaling, costs, strengths and tradeoffs

**Terms used here:** DNS turns a service name into the network address used to reach it.

| Design | Strength | Tradeoff | Growth response |
| --- | --- | --- | --- |
| Native automated backups | No custom backup server/cron required | Timing and supported recovery behavior belong to Azure SQL | Monitor actual backup window and rehearse representative restores |
| Fourteen-day STR | Declared recent-history recovery window | Longer history needs a separate retention design | Agree business retention/RPO requirements and inspect actual availability |
| Geo backup storage | Geographical backup redundancy | Not an online replica or zero-loss failover | Compare restore requirements with separately designed replicas/failover groups |
| Private SQL and Entra-only admin | Reduces public/password administration exposure | Recovery operators need tested DNS/routes and scoped access | Preserve the private path and rehearse custodian access |
| Separate owned recovery database | Preserves the source | Restored identities and extra compute/storage still need control | Budget/expire targets and prove no sender/worker attachment |
| Field/file dependencies | Preserves meaningful whole-platform records | SQL alone cannot restore keys, files or external events | Maintain a dependency inventory and coordinated recovery checks |

RPO is acceptable data loss; RTO is acceptable recovery time. A fourteen-day retention setting describes how far back, not how quickly or how little data a particular disaster recovery loses. Size, transaction replay, target resources and dependencies affect actual time. Local validation elapsed time is not a production RTO.

S0, a recovery database, private endpoints, backup storage and logs can incur charges. This repository creates none. The public capacity input is not measured production size. Review current regional pricing and target lifetime before any apply or drill; do not add long-term retention or a standing replica just to strengthen a portfolio claim.
