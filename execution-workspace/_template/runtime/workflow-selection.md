# Workflow Selection

Schema: `booking.runtime.markdown/v1`

Records: NONE

W01 writes one immutable selection record before the first dispatch and appends a revision record only when evidence changes the route. Each record includes task/profile, selected/skipped/conditional agents, skill triggers, locks, reviewers/gates, assumptions, questions, and stop conditions.
