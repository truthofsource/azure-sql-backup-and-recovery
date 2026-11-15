# Evidence capture plan

Placeholder screenshots were removed on November 15, 2026. Written test results below retain their original dates and scope; historical screenshot references describe earlier captures. Proper Azure and application screenshots are deferred. The illustrated architecture is a source-based explanation, not a live-service screenshot.

The former local workbench captures used fictional metadata and have been removed. No Azure sign-in, resource read, database restore or paid target was used.

Later nonproduction screenshots can show: the exact database's retention/redundancy and earliest point; server networking/Entra settings; Terraform production versus nonproduction plans; and, after a separately authorized rehearsal, an owned restore operation plus safe aggregate validation and cleanup.

Portal path: SQL Database > Backups / Restore to inspect the supported point and target; SQL logical server > Networking and Microsoft Entra administration for access controls. Names vary. Submitting Restore creates an operation and potentially billed resources; do not click it just to obtain a screenshot.

Hide tenant/subscription/object IDs, database/employee content, private URLs, connection strings and tokens. Keep a configured policy screenshot separate from a successful restore receipt. A screenshot of a preview form is not completed recovery evidence.
