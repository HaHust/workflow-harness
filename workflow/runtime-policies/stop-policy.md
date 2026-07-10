# Stop Policy

W01 must mark `BLOCKED` when:

- Required input is missing and cannot be recovered.
- Business, security, release, or migration decision needs a human.
- Permission or lock scope is insufficient.
- Backward compatibility or data safety cannot be proven.
- Debate reaches max rounds without accepted decision.
- Same root cause repeats beyond budget.

Blocked output must include `blocked-report.md`, updated `questions.md`, and updated `risks.md`.
