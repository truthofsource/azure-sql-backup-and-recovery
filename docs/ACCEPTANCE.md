# Acceptance and evidence boundaries

**Terms used here:** DNS turns a service name into the network address used to reach it.

| Evidence | What it establishes | What it does not establish |
| --- | --- | --- |
| Actual module and production overrides | Declared S0/Geo/14-day policy and private/Entra infrastructure | Fresh live backup inventory |
| October 4 module migration receipt | Six identity-preserving no-op address moves, zero-change post-plan | Any database restore or new backup setting change |
| Original SQL rehearsal contract | Prepared isolation, cost and acceptance requirements | Executed recovery or production authorization |
| Terraform tests using simulated cloud responses | Planned module values and private/identity/DNS contract | Azure API acceptance or network access |
| Public Python tests/screenshots | Fictional request guards and explicit non-submission | Available restore point, data recovery or measured cloud RTO |

The later runbook expressly says the isolated rehearsal was prepared, not executed. This project preserves that status. A real drill needs a current supported target/method, private route, contained-permission review, safe data validation, cleanup and an aggregate receipt.

This refresh starts no service, reads no production database and submits no restore. No hosted Actions run is needed for the local evidence.
