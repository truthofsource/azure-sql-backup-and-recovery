# Architecture and trust boundaries

**Terms used here:** A nonce is a value used once for a particular encryption key. A private endpoint gives a supported service an address on a private network; access permissions still apply.

The operational API reaches Azure SQL through the selected private endpoint and private DNS link. Entra-only administration and TLS are declared in the actual module. Application roles, database-contained identities and query permissions are other layers, not established merely by this infrastructure existing.

Azure SQL handles native backup creation and recovery. Production's explicit fourteen-day retention and Geo backup storage differ from the shared module's nonproduction defaults. Backups are not a public Blob container managed by our uploader, and the selected source does not create a running geo-secondary or a backup VM.

The recovery boundary has three dimensions: exact database/source point, exact owned target, and who/what can reach that target. Contained users can survive recovery; blocking public networking alone does not isolate trusted workloads already inside the network. Never attach a restored connection string to the running API, jobs or senders as part of a read-only rehearsal.

Application-level encrypted fields depend on their wrapped data keys, exact Key Vault versions, nonce/tag and authenticated record context. Files depend on Blob bytes and authoritative ownership/scan/revision metadata. SQL PITR alone is not whole-platform recovery. See [the broader recovery project](https://github.com/truthofsource/azure-backup-and-recovery) and [the encryption wrapper](https://github.com/truthofsource/azure-envelope-encryption).

Source layers: actual Terraform module; explicit public environment wrapper; original prepared rehearsal contract; newly authored Python readiness model. These are labeled independently in [SOURCE-MAP](SOURCE-MAP.md).
