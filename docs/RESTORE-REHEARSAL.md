# Prepared restore rehearsal — not executed

The actual procedure was prepared for an isolated SQL recovery exercise. A historic expected schema value of 181 appears in its contract; it is not a declaration of today's live schema. Refresh the source identity, complete ledger and available point before a real exercise.

1. Inspect the exact source, backup policy, earliest available point and supported recovery method. Retain raw metadata privately.
2. Review the disposable target, budget/lifetime and private caller path. A distinct name is not sufficient isolation.
3. Review contained users and custodian-only permissions before restored data becomes reachable. Keep application/provider/sender bindings unchanged.
4. Select the correct method. The standard documented CLI PITR operation creates a new database on the source logical server. A dedicated-server requirement needs an additional supported recovery/copy design and controls for any intermediate database. Geo-restore is a separate operation and does not mean arbitrary PITR in another region.
5. In a separately authorized exercise, submit only the owned target and exact selected point/method. This public repository has no cloud restore adapter or submit action.
6. Validate completion, the expected ledger/schema, safe aggregates, constraints and permissions. Check the appropriate Blob and field-encryption dependencies separately. The [read-only SQL example](../queries/isolated-restore-validation.sql) is a starting point, not an exhaustive acceptance suite.
7. Measure elapsed recovery time and the selected point's data-loss window. Do not label local checker milliseconds as production RTO.
8. Keep source bindings unchanged. Cutover is a separate business/technical decision. Remove only owned target/grants after preserving aggregate evidence and verifying source health.

The local checker supports only the documented same-server preparation mode and never submits it. Fictional readiness flags are inputs to demonstrate holds; they do not discover permissions or network reachability. Incomplete source evidence must remain a hold in a real implementation.

## Recovery methods and command traps

`az sql db restore` and `az sql db copy` have different options and semantics. Do not transfer --dest-server from the copy command into a PITR command without checking support. Consult [the CLI reference](https://learn.microsoft.com/en-us/cli/azure/sql/db?view=azure-cli-latest). The project deliberately provides no executable mutating restore command.

Restoring data does not undo later external effects such as sent messages or provider transactions. Reconcile such operations before any real cutover; do not blindly rerun recovered queue work.
