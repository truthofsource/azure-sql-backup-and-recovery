# Troubleshooting lessons from the actual platform

These are historical engineering incidents summarized from maintained internal records. They are not newly reproduced tests, a fresh cloud inventory or instructions to repeat a consumed operation. Names, resource identifiers, private payloads and credentials are excluded.

## A correct schema still lacked required application grants

**What happened.** A production application-review action failed when updating admin notes, despite successful authentication. A broader review then found missing effective write permissions for selected shift-note and timesheet operations.

**What the evidence showed.** The review statement updated five columns, but an earlier migration granted UPDATE on only four. Operation-level inspection compared actual SQL statements with direct grants, schema/database grants and role membership. The record does not establish that historical manual grants explained a different nonproduction result.

**What changed and how it was checked.** Migration 125 added the exact runtime grants. Metadata checks and zero-row operation probes impersonated the application user inside a rolled-back transaction in both environments. Those probes changed no business rows; they did not replace the separately required signed-in retry of the original business action.

**What to carry forward.** A recovered schema and a successful administrative query do not prove that the application can use the database. Compare the complete migration ledger, effective runtime permissions and intended operation types, then keep structural acceptance separate from functional acceptance. This permission incident is not a claim that an Azure SQL restore rehearsal was completed.

Source record: `docs/troubleshooting/production-api-sql-write-grants-20261006.md` — October 6, 2026. The path identifies internal provenance, not a public file link.

## Evidence and project boundaries

The local examples and screenshots in this repository remain separate from the dated hosted incidents above. A new documentation summary does not establish another successful deployment, restore, security scan or business transaction. Follow the repository’s existing validation guide for the commands and limits of the runnable reference.

The practical sequence is: identify the failing boundary, preserve safe correlation evidence, reconcile any uncertain result, apply only the relevant repair and verify the resulting state. A completed local command is not interchangeable with a completed cloud operation.

## Related project details

- [Application permission incident](https://github.com/truthofsource/api-business-logic-and-workflow-controls/blob/main/docs/LESSONS-LEARNED.md)
