---
description: When to offload a decision to the Jev judgment tools (jev_judge, jev_route, jev_rerank, jev_verify) instead of reasoning it out inline
alwaysApply: true
---

# Jev judgment offload

`omp-jev-tools` exposes TypeSafe's Jev model as `jev_judge`, `jev_route`,
`jev_rerank`, `jev_verify`, `jev_models`. Jev returns only typed verdicts
(probability, picked label, score) — never prose, code, or edits. Roughly
230-640 ms and ~$0.02/1k judgments per call.

## Use it

- **Repeated identical judgment over many items** — one `jev_judge` call with a
  map of question ids answers them in parallel. Prefer this over a loop of
  reasoning steps or a subagent whose only job is classification.
- **Wide candidate set before reading** — when `glob`/`grep`/search returns more
  files or snippets than are worth opening, `jev_rerank` picks which enter
  context. This is the highest-leverage use: it trims input to the expensive
  model.
- **Claim needs checking against evidence already in hand** — `jev_verify`.
- **Branch where being wrong is expensive** — `jev_route` returns a handler plus
  an ACT (>0.85) / CONFIRM (0.6-0.85) / ESCALATE (<0.6) gate. Use the gate: on
  CONFIRM ask the user, on ESCALATE do not act autonomously.

## Do not use it

- A judgment answerable from code already read this turn. A network round-trip
  to confirm what is on screen is strictly worse than deciding.
- One-off decisions. The win comes from batching or from context trimming.
- Anything needing generated text, code, edits, or explanation — Jev cannot
  produce them.
- As a substitute for `lsp`, `grep`, or reading the source. Jev judges; it does
  not discover facts.

## Operational

- Requires `TYPESAFE_API_KEY` in `~/.omp/agent/.env`. If a call fails (missing
  key, API down), fall back to reasoning inline and carry on — never block work
  on Jev.
- Report a Jev-derived decision as such when it drove an action, so the
  confidence number is visible rather than laundered into flat assertion.
- `/jev is <question>? <text>` is the user-facing interactive shortcut.
