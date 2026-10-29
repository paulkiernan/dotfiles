---
name: omp-model-upgrade
description: "Decide whether and where to repoint OMP model roles when a vendor ships a new model, and apply the change safely. Use when Paul says a model was released, asks to upgrade/swap/adopt a model, asks \"should X replace Y\", or asks to update OMP's model choices."
---

# Upgrading OMP's model choices

A new model is not a reason to change anything. It is a reason to run this
procedure, which usually ends in changing **one or two lines**, sometimes none.

Three independent ways this goes wrong, in increasing order of how often they
actually bite:

1. **Choosing wrong** — the new model is not better *for that role's work*.
2. **Missing a site** — a model id is pinned in more places than the role map.
3. **Trusting the catalog** — a days-old model's capability row in OMP is often
   a clone of its predecessor's, so it lies about what the endpoint accepts.

Number 3 is the one that produces a swap that looks clean, passes a smoke test,
and then throws HTTP 400 on a code path you did not exercise. Never skip §3.

## Stop conditions

Do not proceed past the step that fails. A refusal is a valid deliverable.

- No vendor announcement **and** vendor docs page → rumor. Stop.
- The id does not resolve in `omp models` after a refresh → not available to
  this account. Stop, and say "documented but unavailable here".
- The id resolves in `omp models` but a real request with fallback disabled
  returns an error while the incumbent succeeds → **the account cannot use it
  yet**. Stop. Do not ship the role change; a live fallback will hide the
  failure and quietly spend a different provider's quota.
- Only the vendor's own benchmark table shows it ahead → insufficient. Say so.
- The incumbent is Active and not deprecated → there is no deadline. The swap
  must justify itself on merit, and "it is newer" is not merit.

## 0. Where model pins actually live

`~/.omp/agent/config.yml` is a **stow symlink** into
`~/workspace/github.com/paulkiernan/dotfiles/omp/.omp/agent/config.yml`.
Editing the live config edits a tracked git repo file. So does `/model` and
`omp config set` — OMP resolves the symlink and writes through it, debounced,
under `config.yml.lock`, keeping a one-generation `config.yml.bak`. Two
consequences:

- Every swap ends with a dotfiles commit. Check `git -C ~/workspace/github.com/paulkiernan/dotfiles status`.
- OMP re-serializes the YAML, so **comments and key order are not preserved**.
  Do not put explanatory comments in `config.yml`; they will be eaten.

Pins by layer, in descending authority:

| Layer | Files | Notes |
|---|---|---|
| Global config | `~/.omp/agent/config.yml` | `modelRoles`, `retry.fallbackChains`, `modelProviderOrder`, `providers.*` |
| Opt-in overlays | `~/.omp/agent/overlays/*.yml` | Only via `omp --config <f>` or `PI_CONFIG_FILES`. Deep-merged **above** global |
| Other harnesses | `~/.pi/agent/settings.json`, `~/.claude/settings.json`, `~/.codex/config.toml`, `<repo>/.claude/agents/*.md` | Separate agents, separate credentials |
| Restatements | `models.db`, `cache/composer/*/welcome.json`, `~/.pi/agent/models-store.json`, `agent/memories/**` | Never authoritative, never edited |

Two traps in that last row. `~/.pi/agent/models-store.json` is a stale generated
catalog — it lagged a real release by a day. And `agent/memories/**` contains
old `modelRoles` snapshots that `recall` will surface as if they were current
config; read the file, never the memory.

**Sites that must NOT change on a model swap.** They are indirection, and
"fixing" them breaks the indirection:

- `task.agentModelOverrides` — maps agent names to role aliases (`@scout`,
  `@critic`, `@sentinel`, `@smol`, `@task`). Absorbs a role swap automatically.
- `cycleOrder` — role names, not models.
- Glob keys in `retry.fallbackChains` (`anthropic/*`) — cover future ids too.

## 1. Prove the model is real

Require **both** the vendor announcement and the vendor docs/model page. Read
the release date out of the page body, not from a search snippet and not from
what Paul said — release dates are routinely reported a day off, and being
wrong here poisons every "is the benchmark lag or weakness" judgment later.

Record the exact API id string per platform. They differ (`claude-opus-5-5` on
the Claude API vs `anthropic.claude-opus-5-5` on Bedrock).

## 2. Prove it is available here

```sh
omp models find <name>                 # human table
omp models --json | jq -r '.models[] | select(.id|test("<pat>")) | {id,provider,cost,contextWindow,maxTokens,thinking}'
```

Presence in `omp models` means the registry resolved the id **and** a
credential is resolvable — it renders `getAvailable()`, and there is no auth
field in the JSON. Treat that as necessary, not sufficient.

**Catalog presence is not endpoint acceptance.** `omp models` proves the
registry resolved the id and a credential exists. It does *not* prove the
provider will serve it to this account. Subscription/OAuth paths gate models on
things the catalog cannot see — most notably a **client version gate**: the
endpoint can reject a brand-new id because the harness advertises an older
first-party client version, long after the id appears in `omp models`.

So prove it with a real request, and disable fallback while you do — otherwise
you are measuring the fallback, not the model:

```sh
cat > /tmp/nofallback.yml <<'YAML'
retry:
  modelFallback: false
  usageAwareFallback: false
YAML
omp -p --config /tmp/nofallback.yml --model <provider>/<id>:<effort> "Reply with exactly: OK"
```

Run the **incumbent** through the identical command as a control. "New id 400s,
incumbent returns OK" isolates the model; "both fail" is an auth or quota
problem and a different investigation.

Without `modelFallback: false` this test is worthless. With fallback on, a
rejected model silently hands the turn to the next chain entry and prints a
perfectly good answer from a different model — which reads as success.

Pitfalls, all of which produce a false "not available":

- `ls`/`find` read a **24 h cache**. Only `omp models refresh` forces the
  network — that is the supported replacement for deleting `models.db`.
- A static-fingerprint match can short-circuit the merge, so a refresh that
  appears to change nothing is expected behaviour, not a failure.
- `--json` top level is `{"models":[…]}`, **not** an array. `jq '.[]'` silently
  yields nothing. Use `.models[]`.
- jq fabricates keys: `{id, premiumMultiplier}` prints `null` for a field the
  CLI never emits. Never infer a field exists from jq output.
- `omp models` defaults to `--kind chat`. Non-chat models are invisible.
- `disabledProviders` is checked **before** credentials. No key resurrects a
  disabled provider.
- The catalog carries **no release, date, or knowledge-cutoff field at all**.
  Every "this is newer" claim must come from the vendor.

## 3. Read the breaking-changes page, then distrust the catalog

Read the vendor's "what's new" / migration page end to end. Separate:

- **Hard failures** — request shapes that now 400 (disabled thinking, forced
  tool choice, dropped tool versions, prefix-mismatch enforcement).
- **Silent changes** — output that moves or goes quiet without erroring, or a
  changed **default effort**. A model whose default effort dropped a level will
  quietly do less work if the role value has no explicit suffix.

Then check whether OMP's catalog knows any of it. A model merged from the
shared catalog inherits capability flags from class rules, so a brand-new row is
frequently a byte-for-byte capability clone of its predecessor with new prices.

```python
import sqlite3, json, os
con = sqlite3.connect(os.path.expanduser("~/.omp/agent/models.db"))
blob = con.execute("select models from model_cache where provider_id=?", ("anthropic",)).fetchone()[0]
m = {x["id"]: x for x in json.loads(blob)}
NEW, OLD, SIB = "claude-opus-5-5", "claude-opus-5", "claude-fable-5-1"   # sibling = same generation, known-correct
for k in sorted(set(m[NEW].get("compat", {})) | set(m[SIB].get("compat", {}))):
    a, b, c = (m[i].get("compat", {}).get(k) for i in (OLD, NEW, SIB))
    if a != b or b != c:
        print(f"{k:42} old={a!s:>6} new={b!s:>6} sibling={c!s:>6}")
print(NEW, json.dumps(m[NEW].get("thinking")))
print(SIB, json.dumps(m[SIB].get("thinking")))
```

Read the result against the vendor's breaking-changes list. If the new row
matches the **incumbent** on a flag where the vendor says behaviour changed, and
a same-generation **sibling** already encodes the new behaviour, the catalog row
is stale. That is a finding, not a footnote.

**Remediation when the row is stale.** The `models.yml` schema is
**permissive**, and that is the trap. Unknown `compat` keys load without a
warning *and* reach the transport; unknown `thinking` keys load without a
warning and are silently discarded during normalization. "It loaded clean" is
not evidence an override is honored.

`compat` flags are correctable, including ones the docs do not list. This is
wire-verified:

```yaml
providers:
  anthropic:
    modelOverrides:
      claude-opus-5-5:
        compat:
          supportsForcedToolChoice: false
```

`thinking` sub-keys are not. A `thinking` override **replaces** the catalog's
block wholesale, and normalization keeps only `mode`, `efforts`,
`defaultLevel`, `effortMap`, `supportsDisplay`, and `requiresEffort`. Anything
else is dropped. So such an override buys nothing — and applied to a model that
*did* carry the dropped key, it silently turns that behaviour **off**. Omitting
`efforts` is worse: a hard validation failure that disables **every** custom
provider in the file.

Two things that will not help, both measured rather than assumed:

- `omp models refresh` does not repair capability flags. They are rule-owned
  axes derived from model identity; the shared catalog merges new ids additively
  and never rewrites them.
- `models.db` does not reflect `modelOverrides` at all (it does reflect
  provider-level overrides), so the cache cannot confirm your fix landed.

**Verify an override on the wire.** Point the provider at a local mock endpoint
inside a throwaway config root and read the request body. Note `PI_CONFIG_DIR`
is joined under `$HOME`, so pass a bare name, not an absolute path — an absolute
value silently becomes `~/<path>`. Confirm isolation before writing anything.

If the flag is not correctable and the behaviour matters, the swap is **blocked
on the harness, not on the model**. Keep the incumbent, name the flag and the
code path that would hit it, and file upstream. Do not ship the role change and
hope.

## 4. Inventory every pin

Mechanical, not judgment. Run all of it; report what is clean.

**OMP tool calls** (not shell — these are the `read` and `grep` tools, with
`path` and `pattern` parameters):

- `read` → `~/.omp/agent/config.yml` — the surface that matters most; read it
  whole, with line numbers.
- `grep` → pattern
  `opus|fable|sonnet|haiku|gemini|gpt-|deepseek|claude-|anthropic|openai|google|typesafe`,
  over paths `~/.omp/agent/config.yml`, `~/.omp/agent/overlays/`,
  `~/.omp/agent/rules/`, `~/.omp/agent/managed-skills/`.
- `grep` → pattern `model|provider` over `~/.pi/agent/settings.json`.
- `grep` → pattern `^model:` over `~/workspace/github.com/paulkiernan/*/.claude/agents/`.

> **`grep`-tool trailing-slash trap.** Passing a directory as `path` *without* a
> trailing slash returns "No matches found" even when matches exist — verified
> reproducible. A sweep that omits it reports a false clean. Always use `dir/`
> or a `/**` glob. This is a tool behaviour; shell `grep` on a directory instead
> errors with "Is a directory" unless you pass `-r`.

**Real shell:**

```sh
# the stow origin must be byte-identical
diff ~/.omp/agent/config.yml ~/workspace/github.com/paulkiernan/dotfiles/omp/.omp/agent/config.yml

# other harnesses
grep -E '"(model|defaultModel)"' ~/.claude/settings.json
grep -E '^model' ~/.codex/config.toml

# the committed state can differ from the live file — check both
git -C ~/workspace/github.com/paulkiernan/dotfiles diff -- omp/.omp/agent/config.yml

# sites that would exist but may not — confirm each time
for p in ~/.omp/agent/models.yml ~/.omp/agent/models.yaml ~/.omp/agent/models.json \
         ~/.omp/profiles; do [ -e "$p" ] && echo "EXISTS $p" || echo "absent $p"; done
```

The same concrete id usually appears more than once. A role value and a
`retry.fallbackChains` entry are both hard pins; swapping the role and leaving
the chain means a quota-exhausted session silently lands on the old model while
everything else moved. Grep for the id, not for the role.

## 5. Decide per role

A role is not a quality tier. It is a *workload*. Ask what calls it, how often,
and what it actually needs — then whether the candidate is better at that.

| Role | Called by | Needs | Bar for swapping |
|---|---|---|---|
| `default` | Every user turn; also memory extraction | Tools, long context+output, prompt caching, reasoning | Highest scrutiny, most visible regression. Only role where cost genuinely compounds |
| `plan` | Manual (`--plan`, Alt+M). Not in `cycleOrder` | Strongest reasoning, long context, read-only tools | Escalation tier. Keep the stronger model unless it is beaten at equal effort |
| `slow` | `--slow`, Ctrl+P cycle, eval `completion(model="slow")` | Top of the effort ladder; latency irrelevant | Same as `plan`. This is the deliberate "go deep" switch |
| `task` | Every spawned subagent (fan-out to 16) | Reliable tool loops, large context, cheap, latency-tolerant | Cost × concurrency dominates. Tool-calling reliability over raw reasoning |
| `smol` | prewalk target, plan-yolo, `sonic` agent, eval smol tier | Fast edit/write loops, low cost | A weak `smol` shows up as degraded edits *mid-session*, after the first todo — not at startup |
| `tiny` | Session titles, task card labels (fire-and-forget) | Tiny context, short output, **no tools** | Almost never worth changing |
| `commit` | `omp commit` | Diff reading, short deterministic output | Low stakes |
| `vision` | `read <img>?q=…` delegation | **Image input mandatory**, short output | Verify modality before anything else |
| `advisor` | After every completed turn | Tools, its own context window, **different family from `default`** | A broken advisor goes inactive **silently** (`no_model`). Verify explicitly |
| `scout` | `scout` subagent, highest fan-out | Cheap, fast, large input (verbatim reads) | Cost × volume |
| `critic` | `reviewer` subagent | Tools, diff-scale context, high reasoning, **different family from the author** | Family diversity is the point; do not collapse it |
| `sentinel` | `security-reviewer` subagent | Tools, structured output, careful reasoning | `security_scan` records the model into its artifacts — a swap changes finding provenance |

Cross-cutting rules:

- **Pin the effort suffix explicitly, always.** Defaults differ per model, and
  an unsuffixed role silently inherits whatever the new model defaults to.
- An unsupported effort is **clamped silently** at resolve time and only throws
  at request time. A task spawn *fails* if the model has no supported effort at
  or below `task.maxEffort`.
- Keep `critic`/`advisor` in a different model family from `default`. Same-family
  review is self-confirmation, and it is a convention already encoded in the
  overlays.
- Before assuming a role matters, confirm something consumes it. `designer` is
  currently pinned but has **no consumer** — swapping it has zero runtime
  effect, and saying so is more useful than changing it.

Evidence bar, in order of trust: vendor docs → independent same-day harness →
public leaderboards (absence within ~72h of release is submission lag, not
weakness) → eval orgs → vendor benchmark tables (relative ordering only) →
aggregator blogs (discovery only, never a citation). SWE-bench Verified and
SWE-bench Pro are not gates; both have documented broken-task rates and
contamination. Compare cost **per task**, not per token — a cheaper model that
emits far more output tokens is not cheaper.

## 6. Stage before you commit

Never edit global config first. Build an overlay containing only the roles under
test — overlays deep-merge, so unlisted keys are preserved:

```sh
omp --config ~/.omp/agent/overlays/candidate.yml
```

Then run real work through it. Overlays are strict: a missing file or invalid
YAML is a hard error, not a warning.

If a whole directory should be staged instead, use a project `<repo>/.omp/config.yml`
with just the changed roles. Do **not** use `enabledModels` for staging — it is a
global allow-list whose path-scoped interaction is underspecified, and it
propagates into spawned children.

## 7. Apply and verify

1. Record the prior value verbatim first. That is the rollback.
2. Edit every site from §4 in one pass — role **and** fallback chains.
3. **Start a fresh session.** A config edit does not retarget a running
   session; the live session holds a concrete model, and a newly shipped id may
   not even be selectable until restart.
4. Confirm the session is actually on the new model, not merely configured for
   it. With `retry.modelFallback` on, a session can silently run a fallback most
   of the time and still look healthy; under `fallbackRevertPolicy: cooldown-expiry`
   it switches back and forth on its own.
5. Exercise the role's real workload, including whatever the breaking-changes
   page said now 400s.
6. Verify the advisor still reports a model, since its failure is silent.
7. `git -C ~/workspace/github.com/paulkiernan/dotfiles diff` and commit.

Expect the welcome banner cache and `models.db` to keep naming the old model.
Neither is authoritative.

## Anti-patterns

- Swapping every role to the newest model because it is newest.
- Changing only `modelRoles.<role>` and leaving the same id in a fallback chain.
- Editing `task.agentModelOverrides` — those are role aliases and already follow.
- Quoting a composite benchmark score without its effort level.
- Comparing the vendor's max-effort number against your incumbent's default.
- Treating absence from a leaderboard on release day as a negative result.
- Citing an aggregator blog as corroboration of a vendor claim.
- Declaring success from "it started" without exercising the changed path.
- Swapping a role whose consumer you never identified.
- Declaring a swap verified from a run that had `retry.modelFallback` enabled.

## Worked example

**Trigger.** Anthropic shipped Claude Opus 5.5 on 2026-09-22 (Paul said "today",
which was 09-23 — the date came off the vendor page, not the brief).

**Real, available.** Announcement + docs page agree. `omp models find opus`
lists `claude-opus-5-5`, 1M context, 128K output, efforts `low…max`.

**Numbers.** $4/$20 per MTok vs Opus 5's $5/$25, cache reads $0.20 vs $0.50 —
cheaper on all four axes, identical envelope and effort ladder, so existing
`:high`/`:xhigh`/`:max` suffixes stay valid. Independent same-day evaluation put
it first overall at max effort; the vendor claims ~40% cheaper on typical
workloads and >30% faster output.

**Catalog check — the finding.** The `claude-opus-5-5` row is a capability clone
of `claude-opus-5`: `supportsForcedToolChoice: true`,
`supportsThinkingBindingControls: false`, `thinking` with no `prefixBinding`.
Anthropic documents 5.5 as rejecting forced `tool_choice` with a 400 and binding
thinking blocks to the producing model. The same-generation sibling
`claude-fable-5-1` already encodes exactly that (`false` / `true` /
`prefixBinding: true`). So the row is stale on two flags, and the swap is gated
on that — not on the model being good.

**Exposure — what the stale flags actually cost.** With stock settings a plain
chat turn sends no forced tool choice, so ordinary sessions do not 400. The
reachable paths are a subagent's final-retry forced `yield` (automatic),
plan-mode forced resolve, schema-constrained `completion(schema=…)`,
`--external-thinking`, and `todo.eager: always`. Under heavy subagent fan-out
the first is a real if uncommon hit. The `supportsForcedToolChoice: false`
override closes all of them and is wire-verified. The thinking-binding half is
not locally fixable: OMP cannot send `thinking.block_binding`, so when a
fallback chain switches models and reverts, the handling of mismatched thinking
blocks falls to the account default instead of an explicit `drop_block`.

**Sites.** `claude-opus-5` appears **twice**: `modelRoles.default` and as the
head of the `openai-codex/*` fallback chain. A default-only swap leaves
Codex-exhausted sessions on the old model.

**Role decision, and the outcome.** On merit `default` → Opus 5.5 is
well-supported: strictly cheaper, faster, ahead on independent evaluation.
`plan`/`slow` on Fable 5.1 **stay** — the vendor positions Fable *above* Opus
5.5 and says to escalate only when Opus 5.5 at high effort falls short, which
is exactly what those roles are for.

**But the swap was applied and then rolled back.** With fallback disabled,
`anthropic/claude-opus-5-5:high` returned HTTP 400:
`claude_code_version_too_old` — "Claude Code 2.1.257 does not support this
model; version 2.1.280 or newer is required". The identical control request on
`claude-opus-5:high` returned `OK`. Anthropic gates the new id behind a
first-party client version on the OAuth/subscription path, and the catalog
cannot see that gate: `omp models` listed the id, priced it, and reported its
full effort ladder.

Every earlier "success" was the fallback answering. Two print-mode runs looked
perfect and were served by `openai-codex/gpt-6-astra` — once via the usage
preflight (the account's `Claude 7 Day (Fable)` bucket was 100% consumed, so
OMP reported `0.00× quota left` and auto-deflected a non-interactive session),
and once via the 400. Neither printed a warning.

The lesson that generalizes: **a model swap is verified by the model answering,
with fallback off, against a control — not by a session starting and producing
text.** Re-test when the harness advertises a newer client version.
