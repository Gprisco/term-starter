#!/bin/bash
#
# Deploy this repo to the right locations:
#   .config/nvim  → ~/.config/nvim
#   .zshrc        → ~/.zshrc        (original backed up once to ~/.zshrc.bak;
#                    the first backup is never overwritten)
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
    # Print the header comment: everything after the shebang up to (but
    # excluding) the first `set` line, so the range cannot drift.
    -h|--help) awk 'NR > 1 && /^set / { exit } NR > 1' "${BASH_SOURCE[0]}"; exit 0 ;;
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
  if [ -L "$HOME/.zshrc" ]; then
    if [ "$HOME/.zshrc" -ef "$REPO_DIR/.zshrc" ]; then
      echo "    ~/.zshrc (already a symlink to this repo)"
    else
      # Remove only the link — whatever it pointed at stays untouched.
      # Never `cp` over a symlink: that would write through it.
      link="$(readlink "$HOME/.zshrc")"
      rm "$HOME/.zshrc"
      cp "$REPO_DIR/.zshrc" "$HOME/.zshrc"
      echo "    ~/.zshrc (was a symlink to $link; link replaced, target untouched)"
    fi
  else
    # First backup wins: keep the original pre-deploy file even when
    # install.sh is run again later.
    if [ -f "$HOME/.zshrc" ] && [ ! -e "$HOME/.zshrc.bak" ]; then
      cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
      echo "    ~/.zshrc (backup at ~/.zshrc.bak)"
    fi
    cp "$REPO_DIR/.zshrc" "$HOME/.zshrc"
    echo "    ~/.zshrc"
  fi
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
  # Non-zero: the toolchain is the point of this script — report the skip
  # as a failure so scripts/CI don't mistake it for success.
  exit 1
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
