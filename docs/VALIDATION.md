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

The Python checker/tests are newly authored public reference code. They are not original production restore automation. The Terraform module is actual infrastructure source with neutral labels; simulated cloud-provider operations do not access Azure. Historical SQL module migration evidence shows ownership preservation, not restored data.

The live SQL practice restore remains prepared, not executed. No current backup availability, point-in-time recovery, data-plane permission, private route, contained-user isolation or cloud RTO was tested here. Green readiness inputs are fictional assertions; a real adapter must verify each independently.

Reproduce using [the command reference](COMMANDS.md). No new hosted Actions run, Azure SQL connection, paid target or service activation was used.

## Troubleshooting documentation review — November 7, 2026

Added a README incident summary and a linked historical lessons guide, checking the account against the maintained source records. Documentation checks covered local links, complete incident fields, identifying-information patterns, whitespace and preservation of the existing four-step walkthrough. Shared incidents link to the relevant project details; unresolved causes remain explicit.

This was an editorial update. Application code, tests, Terraform, images, workflow definitions and cloud settings were not changed. Existing functional test counts and screenshots above retain their original scope and dates; no application suite, live scan, paid image request, recovery rehearsal or GitHub Actions run was executed for this documentation pass.

## Tools and utilities documentation review — November 7, 2026

Added a prominent README table naming the relevant tools/services and their jobs. The wording distinguishes actual platform components, operating utilities, selected source adapters, optional preparation and local teaching examples. Relevant step headings name their tools while the four-step order and explanatory sentences remain unchanged.

This editorial pass did not change application code, dependencies, infrastructure, workflows or cloud settings. Existing tests and screenshots retain their original evidence scope; no application suite, live scanner, browser sign-in, paid request or GitHub Actions run was executed for this wording update.
