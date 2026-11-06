# Validation — November 6, 2026

| Local check | Result |
| --- | --- |
| Public readiness tests | 16 passed |
| Demonstration assertions | 7 passed; no restore submitted |
| Actual SQL module mock plans | 3 passed |
| Standalone Terraform root | Valid; no apply |
| Provider reproducibility | Signed azurerm 4.75.0 lockfiles for root/module |
| Desktop/mobile browser | Passed; 390 px mobile, no horizontal overflow/runtime errors |
| Loopback negative paths | External-Origin write rejected; unlisted asset rejected |
| Workflow lint | actionlint 1.7.12 passed; manual-only |
| Cloud queries, restores, creates | Zero |

The [machine record](validation-results.json) contains date and source hashes. Screenshots are real local execution with fictional metadata.

The Python checker/tests are newly authored public reference code. They are not original production restore automation. The Terraform module is actual infrastructure source with neutral labels; mocked providers do not access Azure. Historical SQL module migration evidence shows ownership preservation, not restored data.

The live SQL restore rehearsal remains prepared, not executed. No current backup availability, point-in-time recovery, data-plane permission, private route, contained-user isolation or cloud RTO was tested here. Green readiness inputs are fictional assertions; a real adapter must verify each independently.

Reproduce using [the command reference](COMMANDS.md). No new hosted Actions run, Azure SQL connection, paid target or service activation was used.
