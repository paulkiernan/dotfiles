# omp — oh-my-pi config

Global config for [oh-my-pi](https://github.com/can1357/oh-my-pi) (`omp`), current as of 2026-09-20.
A GNU stow package like every other directory here: `stow -t "$HOME" omp` symlinks `.omp/agent/*`
into `~/.omp/agent/`. Secrets never enter the repo — keys live in the untracked
`~/.omp/agent/.env`, OAuth in omp's own credential store.

```
omp/
└── .omp/agent/
    ├── config.yml          roles, fallback chains, Jev judgment backend, subagents
    ├── models.yml          provider overrides (DeepSeek V4.1 Flash metadata fix)
    ├── .env.example        key template (copied to .env by bootstrap.sh)
    └── overlays/
        ├── flat-rate.yml   Codex-first, no metered Anthropic tokens
        └── deepseek-only.yml  everything on DeepSeek
```

## Who does what

| Role | Model | Why |
|---|---|---|
| `default` | `anthropic/claude-opus-5` (effort = auto) | main turn; Jev classifies difficulty per turn |
| `plan` / `slow` | `anthropic/claude-fable-5-1` :xhigh / :max | strongest planner; $10/$50 so only here |
| `task` | `deepseek/deepseek-flash:high` | subagent workhorse, `/vibe` "good" tier |
| `smol` `tiny` `commit` `scout` | `deepseek/deepseek-flash:low` | fan-out, titles, memory, commits, code locating |
| `critic` → `reviewer` agent | `openai-codex/gpt-6-astra:high` | review by a different family than the author, on the ChatGPT plan (see Sharp edges — `designer` is the exception) |
| `sentinel` → `security-reviewer` | `google/gemini-3.8-flash:high` | 1M-context recall over diff + callers |
| `vision` | `google/gemini-3.8-flash:medium` | image / video / audio / PDF input |
| `designer` | `openai-codex/gpt-6-astra:high` | UI work; frontier tier at no marginal cost on the ChatGPT plan |
| `advisor` | `google/gemini-3.8-flash:low` | second model watching every turn (`/advisor off` to silence) |

Typed judgments (auto-thinking level, unexpected-stop detection, AI git staging, `judge()` in eval cells)
go to **TypeSafe Jev** via `providers.judgmentProvider` whenever `TYPESAFE_API_KEY` is set. Jev is
decision-only (max output tokens = 0), so it is never a `/model` target — that is by design.

Fallback chains hand the rest of a turn to the next provider on 429 / quota / outage and revert
when the cooldown lapses. DeepSeek is the catch-all.

## Auth

| Provider | How | Notes |
|---|---|---|
| `deepseek` | `DEEPSEEK_API_KEY` | model id is `deepseek-flash` (V4.1 Flash). `deepseek-v4-flash` still resolves but is retired. |
| `anthropic` | `ANTHROPIC_API_KEY` | **Not Claude Max OAuth.** Anthropic's terms restrict Free/Pro/Max OAuth to Claude Code and claude.ai; since April 2026 third-party harnesses using a subscription token are billed from extra usage per token anyway, so there is no upside. Keep Max for Claude Code; give omp a Console key. |
| `openai-codex` | `/login openai-codex` | ChatGPT OAuth. OpenAI has publicly endorsed third-party harnesses (pi, OpenCode) on ChatGPT plans. Astra needs a Plus/Pro/Business plan. |
| `google` | `GEMINI_API_KEY` | Gemini API. `google-gemini-cli` and `google-antigravity` are disabled in config: the former no longer serves individuals, the latter's terms forbid third-party clients. |
| `typesafe` | `TYPESAFE_API_KEY` or `/login typesafe` | Jev. `omp config get providers.judgmentProvider` |

## Install

`./bootstrap.sh` from the repo root stows this package along with the rest and seeds `.env`.
To do just omp:

```sh
stow -t "$HOME" omp          # or: stow -R -t "$HOME" omp  to restow
cp -n omp/.omp/agent/.env.example ~/.omp/agent/.env && chmod 600 ~/.omp/agent/.env
$EDITOR ~/.omp/agent/.env
omp                          # then /login openai-codex
```

`~/.omp/agent/.env` is a real file, not a symlink — stow places `.env.example` and the copy stays
untracked. To back the links out: `stow -D -t "$HOME" omp`.

Verify:

```sh
omp models deepseek     # deepseek-flash: 1M ctx, 384K out, low/high/max, vision
omp models google       # gemini-3.8-flash present (else uncomment the block in models.yml)
omp config list         # no "unknown setting" or fallback-chain warnings
omp -p 'hey'            # cheap smoke test through the whole stack
```

Optional Jev tools for the agent itself (community plugin, read it before installing):

```sh
omp plugin install omp-jev-tools      # jev_judge, jev_route, jev_rerank, jev_verify, /jev
```

## Switching profiles

Overlays deep-merge on top of `config.yml` for one process and are never persisted:

```sh
omp --config ~/.omp/agent/overlays/flat-rate.yml       # main turn on Astra (ChatGPT plan)
omp --config ~/.omp/agent/overlays/deepseek-only.yml   # everything DeepSeek
```

Or `export PI_CONFIG_FILES=~/.omp/agent/overlays/flat-rate.yml` in a shell you want to stay cheap.

## Sharp edges

- **omp writes to `config.yml`** (`/settings`, `/model` role assignments). Because stow puts a symlink
  there, those writes land in this repo — `git diff` shows what changed. That is the intended feedback
  loop. `config.yml.lock` and `config.yml.bak` are omp's own runtime droppings and are gitignored.
- **`deepseek-flash` metadata.** omp ≤ 18.1.16 loads the new id as an empty shell (issue #11508); the
  `models.yml` entry replaces it. Keep the entry even after the catalog fix — values are DeepSeek's own.
- **DeepSeek pricing is peak/off-peak.** `models.yml` carries the peak rate; `omp stats` will overstate
  cost by up to 2× for work done in the UTC 16:30–00:30 window.
- **`skills.suggestion: typesafe`** (Jev picks which skill to load per turn) is behind oh-my-pi PR #12373.
  Uncomment in `config.yml` once `omp config get skills.suggestion` stops erroring.
- **`designer` and `critic` are the same family.** Astra writes the UI code and Astra reviews it, so
  the cross-family review this config is built around does not hold for front-end diffs. It does hold
  everywhere else, since `default` is Anthropic. Pin `critic` to an `anthropic/*` model for a UI-heavy
  stretch if the blind spot starts to bite.
- **Advisor doubles input traffic** on the main session. It's on Gemini Flash :low to keep that cheap;
  `advisor.enabled: false` if it isn't paying for itself.
- **Effort ladders differ per model.** DeepSeek: low/high/max. Gemini 3.x: low/medium/high (no minimal).
  Opus 5 / Astra: low→xhigh(+max on Claude). Chains carry their own suffixes so a fallback never asks for
  a tier the target lacks.
- Keys renamed between omp releases show up as startup config warnings — `omp config list` after every
  `omp update`.
