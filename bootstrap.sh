#!/bin/bash
set -eux

# Run from the repo root so `setup/*.sh`, the stow package directories, and
# every relative path below resolve regardless of the caller's CWD.
cd "$(dirname "$0")"

# ~/.local/bin holds `omp` and `pi`. Put it on PATH before anything is
# installed so the rest of this script can find them in the same run.
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

KERNEL=$(uname)

OH_MY_ZSH_DIR="$HOME/.zsh/oh-my-zsh"
POWERLEVEL10K_DIR="$HOME/.zsh/zsh_custom/themes/powerlevel10k"
VUNDLE_DIR="$HOME/.vim/bundle/Vundle.vim"

# OS setup ---------------------------------------------------------------------
# Sourced in a subshell: the setup scripts `cd` around (arch.sh chowns and
# builds yay under /opt) and the stow step below depends on staying in the repo.
if [ "$KERNEL" = 'Linux' ]; then
    # /etc/os-release is present on every systemd-era distro; lsb_release is
    # often not installed at all, so only fall back to it.
    DISTRO_ID=""
    DISTRO_LIKE=""
    if [ -r /etc/os-release ]; then
        DISTRO_ID=$(. /etc/os-release && printf '%s' "${ID:-}")
        DISTRO_LIKE=$(. /etc/os-release && printf '%s' "${ID_LIKE:-}")
    elif command -v lsb_release >/dev/null 2>&1; then
        DISTRO_ID=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    fi

    case "$DISTRO_ID $DISTRO_LIKE" in
        *arch*|*manjaro*)
            ( . setup/arch.sh )
            ;;
        *ubuntu*|*debian*|*parrot*|*linuxmint*|*pop*)
            ( . setup/ubuntu.sh )
            ;;
        *)
            echo "Never heard of that Pokemon."
            exit 1
            ;;
    esac

    ZSH_BIN=$(command -v zsh || true)
    if [ -n "$ZSH_BIN" ] && [ "${SHELL:-}" != "$ZSH_BIN" ]; then
        sudo usermod -s "$ZSH_BIN" "$USER"
    fi
elif [ "$KERNEL" = 'Darwin' ]; then
    ( . setup/osx.sh )
    if [ -d /opt/homebrew/bin ]; then
        export PATH="/opt/homebrew/bin:$PATH"
    elif [ -d /usr/local/bin ]; then
        export PATH="/usr/local/bin:$PATH"
    fi
fi

# ASDF + toolchains -----------------------------------------------------------
ASDF_DIR="$HOME/.asdf"

# Known-stable toolchain versions (explicit pins; `latest` can resolve to
# free-threaded/experimental builds that break installs).
# Python is intentionally NOT installed here: asdf builds it from source,
# which needs sudo + system build deps (libssl-dev etc.) on every machine.
# Node and rust ship precompiled binaries, so they install without compilation.
ASDF_NODEJS_VERSION="24.19.0"
ASDF_RUST_VERSION="1.97.1"

echo "Installing/Upgrading ASDF"
if ! command -v asdf >/dev/null 2>&1; then
    if [ ! -d "$ASDF_DIR" ]; then
        git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR"
    elif [ -d "$ASDF_DIR/.git" ]; then
        git -C "$ASDF_DIR" pull --ff-only || echo "✗ Failed to update asdf"
    fi
fi

# Always export for the rest of this script, whether asdf was already installed
# or just cloned. shims/ matters: `asdf install nodejs` drops npm there, and the
# pi step below needs npm on PATH.
export PATH="$ASDF_DIR/shims:$ASDF_DIR/bin:$PATH"
if [ -s "$ASDF_DIR/asdf.sh" ]; then
    . "$ASDF_DIR/asdf.sh"
fi

if ! command -v asdf >/dev/null 2>&1; then
    echo "ERROR: asdf not found on PATH after install" >&2
    exit 1
fi

echo "Installing asdf plugins (nodejs, rust)"
for plugin in nodejs rust; do
    if ! asdf plugin list | grep -qx "$plugin"; then
        asdf plugin add "$plugin"
    else
        echo "  plugin $plugin already present"
    fi
done

echo "Installing known-stable toolchains via asdf"
asdf install nodejs "$ASDF_NODEJS_VERSION"
asdf install rust "$ASDF_RUST_VERSION"

# `asdf set -u` is the modern form; older asdf uses `asdf global`.
if asdf set --help >/dev/null 2>&1; then
    ASDF_SET="asdf set -u"
else
    ASDF_SET="asdf global"
fi
echo "Setting global tool versions"
$ASDF_SET nodejs "$ASDF_NODEJS_VERSION"
$ASDF_SET rust "$ASDF_RUST_VERSION"

# Set up all dotfile symlinks -------------------------------------------------
echo ""
echo ">> Setting up dotfile symlinks with stow"
echo ""

# omp keeps runtime state (agent.db, stats.db, logs/) in ~/.omp, and pi does the
# same in ~/.pi (auth.json, trust.json, sessions/, vendored rg+fd). ~/.agents
# holds the one instruction file both harnesses read, plus skills that come from
# their own git repos. Each target directory must exist before stowing or stow
# folds the tree and symlinks the dir itself into this repo, which would put
# that runtime state under version control. Same for ~/.zsh/zsh_custom/themes,
# which bootstrap fills with a git clone.
mkdir -p \
    "$HOME/.omp/agent/managed-skills" \
    "$HOME/.pi/agent" \
    "$HOME/.agents/skills" \
    "$HOME/.zsh/zsh_custom/themes"

STOW_PACKAGES=(docker git linux omp osx pi scripts shared tmux vim zsh)

for package in "${STOW_PACKAGES[@]}"; do
    if [ -d "$package" ]; then
        echo "Stowing $package..."
        stow -t "$HOME" "$package" 2>/dev/null || stow -R -t "$HOME" "$package" || echo "✗ Failed to stow $package"
    else
        echo "✗ Directory $package not found, skipping"
    fi
done

# Ghostty config
mkdir -p "$HOME/.config/ghostty"
if [ -d "ghostty" ]; then
    echo "Stowing ghostty config..."
    stow -t "$HOME/.config/ghostty" ghostty 2>/dev/null || stow -R -t "$HOME/.config/ghostty" ghostty || echo "✗ Failed to stow ghostty"
else
    echo "✗ Directory ghostty not found, skipping"
fi

# pi (https://pi.dev) ---------------------------------------------------------
# Upstream pi runs side-by-side with omp for evaluation; the write-up lives in
# the Notes Obsidian vault at
# personal/Hobbies/Harness Evaluation/Harness Evaluation.md.
# npm global installs under asdf are bound to the active node version and vanish
# on the next `asdf set nodejs <other>`, so pi goes into a fixed prefix and is
# symlinked onto PATH instead of relying on shims.
#
# Config is stowed from the pi package into ~/.pi/agent. Credentials are NOT
# shared with omp (omp uses agent.db, pi uses ~/.pi/agent/auth.json), so run
# `pi` and use /login for each provider.
PI_NPM_PREFIX="$HOME/.local/share/pi-npm"

echo ""
echo ">> Installing/Upgrading pi"
if command -v npm >/dev/null 2>&1; then
    npm install -g --ignore-scripts --prefix "$PI_NPM_PREFIX" @earendil-works/pi-coding-agent \
        && ln -sfn "$PI_NPM_PREFIX/bin/pi" "$HOME/.local/bin/pi" \
        || echo "✗ Failed to install pi"
else
    echo "✗ npm not on PATH, skipping pi install"
fi

# omp (https://omp.sh) -------------------------------------------------------
# The prebuilt binary install writes ~/.local/bin/omp, verifies the sha256,
# smoke-tests `omp --version`, needs no Bun, and never edits .zshrc (this repo
# owns the shell config).
#
# omp authenticates every provider through `/login` (OAuth, or a validated
# api-key prompt for DeepSeek and TypeSafe), storing credentials in its own
# store. Nothing to seed here.
echo ""
echo ">> Installing/Upgrading omp"
if command -v omp >/dev/null 2>&1; then
    omp update || echo "✗ Failed to update omp"
else
    curl -fsSL https://omp.sh/install | sh -s -- --binary || echo "✗ Failed to install omp"
fi

# Agent skills (external git repos) ------------------------------------------
# Personal skills are stowed from the `shared` and `omp` packages. Third-party
# skills are their own git repos under ~/.agents/skills, which stow does not
# manage, so they are cloned or fast-forwarded here.
AVOID_AI_WRITING_DIR="$HOME/.agents/skills/avoid-ai-writing"

echo ""
echo ">> Installing agent skills"
mkdir -p "$HOME/.agents/skills"
if [ -d "$AVOID_AI_WRITING_DIR/.git" ]; then
    echo "Updating avoid-ai-writing skill..."
    git -C "$AVOID_AI_WRITING_DIR" pull --ff-only || echo "✗ Failed to update avoid-ai-writing"
else
    echo "Cloning avoid-ai-writing skill..."
    git clone https://github.com/conorbronsdon/avoid-ai-writing "$AVOID_AI_WRITING_DIR" || echo "✗ Failed to clone avoid-ai-writing"
fi

echo ""
echo ">> Installing/Upgrading oh-my-zsh"
# Install oh-my-zsh or update if already installed
if [ ! -d "$OH_MY_ZSH_DIR" ]; then
    echo "Installing oh-my-zsh to $OH_MY_ZSH_DIR..."
    git clone https://github.com/robbyrussell/oh-my-zsh.git "$OH_MY_ZSH_DIR" || echo "✗ Failed to install oh-my-zsh"
elif [ -d "$OH_MY_ZSH_DIR/.git" ]; then
    echo "Updating oh-my-zsh..."
    git -C "$OH_MY_ZSH_DIR" pull origin master || echo "✗ Failed to update oh-my-zsh"
else
    echo "✓ oh-my-zsh directory exists (not a git repo)"
fi

echo "Installing/Upgrading Powerlevel10k"
if [ ! -d "$POWERLEVEL10K_DIR" ]; then
    git clone https://github.com/romkatv/powerlevel10k.git "$POWERLEVEL10K_DIR" || echo "✗ Failed to install powerlevel10k"
elif [ -d "$POWERLEVEL10K_DIR/.git" ]; then
    git -C "$POWERLEVEL10K_DIR" pull --ff-only || echo "✗ Failed to update powerlevel10k"
else
    echo "✓ powerlevel10k directory exists (not a git repo)"
fi

echo ""
echo ">> Installing Vundle for vim"
# Install Vundle (updates are managed by `BundleUpdate`)
if [ ! -d "$VUNDLE_DIR" ]; then
    echo "Installing Vundle to $VUNDLE_DIR..."
    mkdir -p "$(dirname "$VUNDLE_DIR")"
    git clone https://github.com/VundleVim/Vundle.vim.git "$VUNDLE_DIR" || echo "✗ Failed to install Vundle"
else
    echo "✓ Vundle already installed"
fi

echo ""
echo "=========================================="
echo "✓ Bootstrap complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Log out and log back in (or run 'exec zsh') to activate zsh"
echo "  2. Run 'vim +PluginInstall +qall' to install vim plugins"
echo "  3. Run 'omp' and use /login for google-antigravity, deepseek, and typesafe"
echo "     (run 'pi' and use /login too if you use Pi)"
echo ""
