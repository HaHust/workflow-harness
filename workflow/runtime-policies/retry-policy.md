# Retry Policy

Default budgets:

| Loop | Max |
| --- | ---: |
| Worker-reviewer repair | 2 |
| Failure analyzer repair | 3 |
| Debate | 3 |
| Full workflow restart | 1 |
| Maintenance optimization | 2 |

After two worker rejects on the same issue, W01 calls F01. If F01 cannot assign a confident owner, W01 blocks and asks the user.
