---
name: obsidian-project-documentation
description: "Document projects in Paul's Notes Obsidian vault using shared conventions; safely publish through Obsidian when vault filesystem access is blocked, and verify content, links, and task visibility."
---

# Documenting projects in the Notes vault

## Start with the shared standard

1. Read `vault://` to identify vaults. Use **Notes** for ordinary project documentation, not the separate Dungeons & Dragons vault unless that is the requested subject.
2. Read the root note `Vault Documentation Conventions.md`. It is authoritative; do not let this skill replace or freeze its evolving details.
3. Inspect the relevant existing project overview, Todo, and minimal template examples. Avoid unrelated private notes. Reuse an existing project rather than creating a parallel hierarchy.
4. Default to `personal/` or `professional/`, then an existing domain/project folder. Use a project-named overview; add `<Project> Todo.md` only for real actions. Evidence/design/decision notes and `Sources/` are optional, material-driven additions.
5. Use the existing Templater templates in `99 - templates/Project Overview Template.md` and `Project Todo Template.md`; do not introduce another templating syntax. Note creation and observation/research dates are different.
6. Keep the current decision prominent. Label observations, hypotheses, assumptions, historical sources, and superseded guidance. One active checklist per project. In this vault `#task` is the Tasks plugin global filter: use it for actionable tasks, not conditional/deferred work. A completed checkbox alone does not establish a completion date.

## Safe publishing

- Prefer specialized `vault://` tools. If they fail with EPERM on a Dropbox/CloudStorage-backed vault, use the existing Obsidian application/CLI; do not change macOS permissions or install/restart software unnecessarily.
- This installation reliably accepts the vault selector **before** the command: `obsidian vault=Notes read path="..."`, `obsidian vault=Notes files folder="..."`, and `obsidian vault=Notes eval code="..."`. Inspect `obsidian help` for current capabilities.
- A bare vault URI may try a blocked filesystem read while supported metadata operations succeed. Native CLI `read` can retrieve note bodies.
- Stage long or escape-sensitive contents outside the protected vault with the normal write tool. Pass a short script containing the **resolved staging path** to CLI `eval`, rather than embedding a large base64 body or escape-heavy text in the command line. Large argument publication stalled in this installation.
- Through the app, read the staged file and use `app.vault.createFolder`, `app.vault.create`, or `app.vault.modify` so Obsidian indexes the changes. Never blindly overwrite: refuse an existing differing note or require its previously observed hash before applying an update.
- App `eval` calls may not await an async IIFE or print its result. Use an explicit synchronous acknowledgement plus a subsequent read-back/hash check. Exit code zero or a startup banner is not proof of persistence.
- Keep one integration owner for vault publication while other agents draft independent local notes. Retain repository originals; archive copies need provenance and superseded-status warnings. No credentials or account secrets in notes.

## Verification

1. Confirm each exact destination exists and its content/hash matches the staged source. Validate copied JSON as JSON. The native app can compute hashes using its filesystem adapter's base path and Node crypto, returning only compact verification data.
2. Check Obsidian metadata-cache link resolution for all new Markdown notes, including frontmatter links and non-Markdown attachments. Resolve every unintended broken link.
3. Check parsed checkbox counts/states and active `#task` visibility. Templates must contain no actual placeholder tasks.
4. Even a Markdown link example inside an Obsidian comment can appear in the link index. Avoid fake `[title](url)` links and unrelated project example links in templates.
5. Templater expressions are expected inside templates, but not unresolved in instantiated project notes. Verify template behavior if changing expressions or integration assumptions.
6. Deliver direct Obsidian links to the overview, Todo, and conventions, summarize the structure, and state what was preserved versus moved/deleted.
