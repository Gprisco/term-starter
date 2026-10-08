#!/bin/bash
#
# Deploy this repo to the right locations:
#   .config/nvim  → ~/.config/nvim
#   .zshrc        → ~/.zshrc        (previous one is backed up)
#   mise.toml     → ~/.config/mise/config.toml  (symlink, so mise.lock
#                    updates land back in the repo)
#
# Then install everything declared in mise.toml.
#
# Usage: ./install.sh [--zshrc]
#   --zshrc   also deploy this repo's .zshrc over ~/.zshrc (backs up first).
#             Off by default: a machine may already have a hand-written
#             ~/.zshrc that this template would clobber.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MISE_CFG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/mise"

DEPLOY_ZSHRC=0
for arg in "$@"; do
  case "$arg" in
    --zshrc) DEPLOY_ZSHRC=1 ;;
    -h|--help) sed -n '2,15p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

echo "==> Neovim config"
mkdir -p "$HOME/.config"
# Remove first: `cp -r` into an existing directory would nest as nvim/nvim.
rm -rf "$HOME/.config/nvim"
cp -r "$REPO_DIR/.config/nvim" "$HOME/.config/"
echo "    ~/.config/nvim"

if [ "$DEPLOY_ZSHRC" = 1 ]; then
  echo "==> zsh config"
  if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
    echo "    ~/.zshrc (backup at ~/.zshrc.bak)"
  fi
  cp "$REPO_DIR/.zshrc" "$HOME/.zshrc"
  echo "    ~/.zshrc"
else
  echo "==> zsh config (skipped — pass --zshrc to deploy it)"
fi

echo "==> mise"
if ! command -v mise >/dev/null 2>&1; then
  cat >&2 <<'EOF'
    mise not found — skipping tool installation.
    Install it, then re-run ./install.sh:
      https://mise.jdx.dev/getting-started.html
EOF
  exit 0
fi

mkdir -p "$MISE_CFG_DIR"
ln -sfn "$REPO_DIR/mise.toml" "$MISE_CFG_DIR/config.toml"
ln -sfn "$REPO_DIR/mise.lock" "$MISE_CFG_DIR/mise.lock"

# The config declares tool options (prerelease = true), so mise requires an
# explicit trust before it will act on it.
mise trust "$REPO_DIR/mise.toml" >/dev/null

# Writes ~/.config/mise/mise.lock, which is the symlink to mise.lock in this
# repo. First run creates it.
mise lock --global

# Installed from the repo directory so the active config is this toolchain
# rather than an unrelated project that happens to have a mise.toml.
(cd "$REPO_DIR" && mise install)

echo
mise ls
echo
echo "Done. Open a new shell (or 'exec zsh') to pick up the mise shims."
