# Security and disclosure

No real database data, tenant/subscription IDs, credentials, connection strings, keys, source plans or state files are included. The SQL module is actual infrastructure source with example labels. Applying it creates resources; local mock tests do not.

The default Python program has no Azure SDK, HTTP client or subprocess adapter. It validates fictional metadata and cannot submit a restore. A prepared result is not authorization. The manual-only GitHub workflow has read-only repository permission and no cloud deployment credentials.

The original rehearsal's prepared-not-executed state is retained. Never attach a recovered database to a running API, provider worker or sender without a separate reviewed cutover and external-event reconciliation. Treat contained users, private connectivity, field-encryption keys and Blob records as separate recovery dependencies.
