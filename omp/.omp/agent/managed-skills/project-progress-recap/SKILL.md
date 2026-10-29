---
name: project-progress-recap
description: "Summarize completed work at the end of any turn that changed files, ran state-changing commands, made a design decision, or abandoned an approach — what was done, why, what proof exists, and where the project now stands. Use for every project, and when Paul asks \"where are we\", \"what did you do\", or \"catch me up\"."
---

# Recap the work after doing it

Paul must be able to read one block at the end of a turn and know what changed,
why, what proof exists, and where the project stands — without reading the
transcript, the diff, or the tool calls.

This is a reporting discipline, not a planning one. Recap **after** the work.
Never present intentions as a recap, and never let writing the recap replace
finishing the work.

## When to write one

- Any turn that changed files, ran a state-changing command, made a design
  decision, or abandoned an approach.
- Any time Paul asks where things stand, what happened, or to be caught up —
  including at the start of a session resuming earlier work.
- Skip it for: a question answered with no changes, a single lookup, or when
  Paul explicitly asked for terse output.

## Shape

Six sections in this order. Omit a section only when it is genuinely empty;
**State** and **Next** are never omitted.

1. **Done** — what now exists that did not before.
2. **Why** — the reasoning and the rejected alternative.
3. **Evidence** — what was run, and what was observed.
4. **Dropped** — what was tried and abandoned, and why.
5. **State** — the whole task, not just this turn.
6. **Next / needs you** — the one next action, or the decision required.

## Rules per section

**Done.** Concrete nouns: file paths, symbol names, commands. "Added retry
around `fetchUser` in `src/api/user.ts`" — not "improved error handling". One
line per real change, grouped by file or feature. Never a tool-by-tool
play-by-play; the sequence of greps and reads is not information.

**Why.** Give the decision and what it beat. Name the forcing constraint when
there was one (an existing convention, an API shape, a prior instruction from
Paul). If a choice was a judgment call with no strong evidence, say so plainly
rather than retrofitting a rationale.

**Evidence.** Name the exact command or check and its observed result. Keep
"the suite passes, 43 tests" strictly separate from "this should work, not
run". Anything not actually observed is marked `[INFERENCE]`. Unverified work
is reported as unverified — that is not a confession, it is the useful part.

**Dropped.** The highest-value section. Record approaches tried and abandoned
with the reason. It stops Paul from re-suggesting a dead end and stops a later
session from re-walking it. A failure that cost real time and left no trace in
the code still belongs here.

**State.** Cover the task end to end, not only today's slice. Mark each piece
`done` / `in progress` / `not started` / `blocked`. Include work deliberately
left undone and say the omission was deliberate. If scope moved, say what moved
and that Paul approved it.

**Next / needs you.** Exactly one next action. If a decision is genuinely
Paul's to make — materially different tradeoffs, not a preference you could
infer — state the options and their consequences here, and stop rather than
guessing.

## Persistence across sessions

Chat scrollback dies. For work spanning more than one session, put the state
somewhere durable as well:

- Project already documented in the **Notes** Obsidian vault → update it per
  the `obsidian-project-documentation` skill. On this machine the vault is the
  authority for project documentation; do not start a parallel hierarchy.
- Otherwise → append to a single dated worklog at a path agreed with Paul.
  Never scatter status files through a repo, and never create one unasked.
- Append-only. Supersede an earlier entry with a newer, dated one that labels
  the old conclusion as superseded; do not silently rewrite history.
- Do not sweep a worklog update into an unrelated commit.

## Anti-patterns

- Tool narration: "then I grepped for X, then I read Y, then I opened Z".
- Completion percentages, or "90% done".
- Claiming a verification that never ran.
- Padding with everything that did not change.
- A blocker buried below the good news. It goes in **Next**, visible.
- Restating the request back as though it were the accomplishment.
- Celebration, emoji, or reassurance. Real progress reads as progress without
  decoration; see `avoid-ai-writing` for the tells to strip.

## Worked example

```
Done
- Added `retryWithBackoff` to src/api/client.ts; `fetchUser` and `fetchOrg`
  now route through it.
- Deleted the ad-hoc retry loop in src/api/user.ts (was 3 fixed 500ms tries).

Why
- Two callers had diverging retry behaviour; one shared helper was cheaper
  than keeping them in sync. Rejected pulling in p-retry — 400 lines of
  dependency for one exponential backoff already in the codebase's style.
- Backoff caps at 8s because the upstream gateway times out at 10s.

Evidence
- `bun test src/api` → 43 passed, 0 failed.
- Hit the staging 429 path by hand: three retries, then success. Logged
  delays 1s/2s/4s as intended.
- [INFERENCE] The org endpoint should behave identically; it shares the
  client but I exercised only the user endpoint.

Dropped
- Tried retrying inside the fetch wrapper itself. Abandoned: it also caught
  4xx auth failures and retried them, tripping the lockout counter.

State
- done: shared retry helper, user endpoint migrated.
- in progress: nothing.
- not started: billing endpoints (src/api/billing.ts) still have their own
  retry loop — left alone deliberately, it has different idempotency rules.
- blocked: none.

Next
- Decide whether billing should share this helper. It needs an idempotency
  key per attempt, which the current helper does not take; adding it changes
  the signature for existing callers.
```
