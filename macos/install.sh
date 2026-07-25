#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BIN_DIR="/usr/local/bin"
BIN="$BIN_DIR/pg27switch"

"$ROOT_DIR/macos/build.sh"

if [[ ! -d "$BIN_DIR" ]]; then
  sudo mkdir -p "$BIN_DIR"
fi

sudo cp "$ROOT_DIR/build/pg27switch" "$BIN"
sudo chmod 755 "$BIN"

mkdir -p "$HOME/Library/Logs/PG27UCDMSwitcher"

echo "Installed $BIN"
shasum -a 256 "$ROOT_DIR/build/pg27switch" "$BIN"
