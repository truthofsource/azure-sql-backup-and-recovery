# Native Azure SQL backups: what each option means

For this Standard S0-style workload, Azure SQL manages full, differential and log backups. The service chooses timing; this portfolio does not schedule a custom backup worker. Retention controls how far back eligible recovery points may be available; inspect the actual earliest restore date rather than subtracting fourteen days and assuming a backup exists. [Microsoft automated backup overview](https://learn.microsoft.com/en-us/azure/azure-sql/database/automated-backups-overview?view=azuresql)

| Mechanism | Purpose | Selected platform evidence |
| --- | --- | --- |
| Point-in-time restore | Recover eligible history into another database | Production source declares 14-day STR; no new live restore performed here |
| Geo backup redundancy | Retain geographically replicated backup copies for geo-recovery | Geo declared; not a running secondary or automatic cutover |
| Long-term retention | Keep selected backups beyond the ordinary short-term window | Not declared by this selected module; live policy not inspected |
| Active geo-replication/failover group | Maintain an online secondary and an explicit failover design | Not provided by this case study |
| BACPAC export | Logical schema/data package for portability | Not this native backup mechanism and not an implemented export schedule here |

These are different recovery products and operations. Do not present a BACPAC file as the transaction-log backup chain or claim automatic failover from the word Geo. [Microsoft restore guidance](https://learn.microsoft.com/en-us/azure/azure-sql/database/recovery-using-backups?view=azuresql)

Storage/service encryption (including TDE) protects the database layer. Application envelope encryption is an additional field-level mechanism whose matching keys/context must also be recoverable. Neither backup redundancy nor encryption alone proves a complete restore.
