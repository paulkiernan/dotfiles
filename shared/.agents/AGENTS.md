# Agent Instructions (shared)

Shared by every coding agent on this machine, regardless of harness, and
injected into every session. Keep this file harness-neutral: no harness-specific
tools, commands, or config. Anything here must make sense to any agent.

## Environment

- Primary workstation is macOS on Apple M3 (arm64). These dotfiles also deploy
  to Linux hosts, so check `uname -s` and `uname -m` rather than assuming
  either OS, a path layout, or a package manager.
- `node` and `rust` are asdf-managed. `bootstrap.sh` holds the pinned versions,
  but the installed toolchain can lag the pin: check `asdf current` rather than
  assuming. Do not install or upgrade them ad hoc.
- Python is deliberately NOT asdf-managed: asdf builds it from source, needing
  sudo plus system build deps. Use `~/.local/bin/python3.12` or `python3.14`.
- `bun` lives at `/opt/homebrew/bin/bun` on Apple Silicon macOS; otherwise
  check `command -v bun`.
- User-level binaries live in `~/.local/bin`; check there before concluding a
  CLI is missing.
- Repos live at `~/workspace/github.com/<owner>/<repo>`.

## Dotfiles (stow)

- Top-level dirs in this dotfiles repo are GNU stow packages symlinked into
  `$HOME`. Never put project documentation or other non-config files inside a
  package directory.
- Stow trap: if the target directory does not already exist, stow folds the
  tree and symlinks the whole directory back into the repo, dragging runtime
  state (databases, logs, credentials) under version control. Mitigation:
  create the target directory before stowing.

## Node tooling

- npm global installs under asdf are bound to the active node version, so they
  vanish when the toolchain changes. User-level CLIs are therefore installed to
  a fixed prefix and symlinked into `~/.local/bin`.

## Procedures and docs

- Reusable procedures live as skills in `~/.agents/skills` and
  `~/.omp/agent/managed-skills`. Prefer an existing skill over improvising.
- Project documentation goes to the Notes Obsidian vault.
