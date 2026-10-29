---
name: dependabot-security-automerge
description: "Set up or review unattended auto-merge of Dependabot security updates on a GitHub repo, including private repos whose plan lacks branch protection, using a trusted workflow_run gate instead of native auto-merge."
---

# Dependabot security auto-merge without branch protection

Use when a repository should merge Dependabot security fixes unattended but native auto-merge or required status checks are unavailable (private repo, free/team-less plan), or when reviewing such an existing setup.

## 1. Decide the mechanism first

Check the platform before designing:

```bash
gh api repos/$OWNER/$REPO --jq '{allow_auto_merge,private,permissions}'   # allow_auto_merge
gh api repos/$OWNER/$REPO/branches/main/protection                        # 403 => no branch protection
gh api repos/$OWNER/$REPO/rulesets                                        # 403 => no rulesets
```

- Protection + native auto-merge available: use `dependabot/fetch-metadata` with `gh pr merge --auto` in a `pull_request_target` workflow, and require the CI checks on the branch.
- Not available (403 on both): build a trusted `workflow_run` gate that verifies CI and performs the merge itself. Say plainly in the docs that this is a merge gate, not branch protection: a human with write access can still push to the default branch.

## 2. Supply side

`dependabot.yml` with one entry per real manifest (e.g. `npm` at `/`, `uv` at `/manual`), each with `open-pull-requests-limit: 0`. That disables version updates while security updates (driven by alerts) keep coming. Never set `target-branch` — it stops the entry's options from applying to security updates. Note that `update-types`/`group`/`cooldown` cannot filter security updates; major/ambiguous bumps must be refused by the gate.

## 3. Gate side

Workflow: `on: workflow_run: [completed]` for the CI workflow, plus a `schedule` backstop and a `workflow_dispatch` (default mode `dry-run`). Set a single repo-level `concurrency` group with `cancel-in-progress: false`. Grant least privilege: `contents: write`, `pull-requests: write`, `issues: write` (comment), `actions: write` (dispatch), `vulnerability-alerts: read` (alert lookup). Check out the default branch with `persist-credentials: false`; install nothing; never check out the pull request ref.

Policy script (stdlib only) merges only when every one of these holds — verify them from live API state, never from the event payload:

- PR authored by the real `dependabot[bot]` (login and `type == Bot`), same-repo head, base = default branch, open, not draft, commits signature-verified.
- A linked OPEN alert: page `repository.vulnerabilityAlerts(states:[OPEN])` and index `dependabotUpdate.pullRequest.number`; require the alert's `vulnerableManifestPath` to match the ecosystem the changed files belong to. Never classify "security" from labels, titles, or commit text.
- The newest CI run for the exact head SHA from the `pull_request` event: correct workflow id/path, `completed`/`success`, and every required job name present and successful. An older green run must not be used when a newer run for that SHA exists.
- `compare/default...head` is `ahead` (the head descends from the current tip) and the tip has not moved since.
- Manifest and lockfile diffs are stable patch/minor increases only, with the registry scheme+host preserved, artifact URLs tracking the new version, and changed artifact hashes. A frozen URL that still names the old version is a fake fix: block it (`str(old_version) in path`).
- No human `CHANGES_REQUESTED` (a later approval or dismissal may clear it; a plain comment must not).
- Re-read the PR, the tip, the CI run (id, `run_attempt`, conclusion) and the reviews immediately before merging, and merge via `PUT /repos/{owner}/{repo}/pulls/{n}/merge` with `{"sha": head, "merge_method": "squash"}`. Never pass `--auto` here and never force.
- Merge at most one candidate per sweep; after a merge every other head is stale by construction.

Exit non-zero when the sweep itself cannot verify (unreadable alerts, truncated lists, wrong workflow or default branch) so a green run never hides a blind gate. Sanitize any PR-derived text before printing it as a workflow command.

## 4. Keep the chain moving

A stale PR can never merge, and Dependabot only rebases on its own schedule or on conflict — so a diverged PR can sit blocked forever. Post the documented `@dependabot rebase` comment for at most one candidate per sweep, only when a rebase is the sole repair (stale branch point, or a required job missing from its run), never twice for the same head commit. Walk past candidates whose request is still outstanding so one ignored nudge cannot deadlock the chain.

## 5. Publish and verify

```bash
# Merge a GITHUB_TOKEN merge cannot start: dispatch the release pipeline.
gh api --method POST repos/$OWNER/$REPO/actions/workflows/release.yml/dispatches -f ref=main
```

Work on a branch and open a PR first: that runs the real CI, including any new required jobs, before they become hard gates. Then verify the live read path with `gh workflow run <workflow>.yml --ref main` (dry run) and read the log: it must print the candidate and alert counts without error. A merge made with GITHUB_TOKEN starts no `push` workflow — if a release/deploy must follow, dispatch it, and guard the deployment against stale runs by comparing the repository's current default-branch SHA with `github.sha`.

## 6. Facts worth not re-learning

- `vulnerability-alerts: read` is a valid `GITHUB_TOKEN` permission and does authorize reading Dependabot alerts (verified live). actionlint older than that change reports it as unknown — a stale schema, not a real failure.
- `GITHUB_TOKEN` merges do not trigger `push` workflows; `workflow_dispatch` does.
- Dependabot's rebase comment command must be written exactly `@dependabot rebase`.
- Free-plan private repos get no branch protection, rulesets, or native auto-merge: that limitation is the reason this design exists.
