#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BIN_DIR="/usr/local/bin"
BIN="$BIN_DIR/pg27switch"
LAUNCHERS_DIR="$ROOT_DIR/macos/launchers"

"$ROOT_DIR/macos/build.sh"

if [[ ! -d "$BIN_DIR" ]]; then
  sudo mkdir -p "$BIN_DIR"
fi

sudo cp "$ROOT_DIR/build/pg27switch" "$BIN"
sudo chmod 755 "$BIN"

mkdir -p "$LAUNCHERS_DIR"

cat > "$LAUNCHERS_DIR/DisplayPort.command" <<'EOF'
#!/bin/zsh
/usr/local/bin/pg27switch dp
EOF

cat > "$LAUNCHERS_DIR/HDMI1.command" <<'EOF'
#!/bin/zsh
/usr/local/bin/pg27switch hdmi1
EOF

cat > "$LAUNCHERS_DIR/HDMI2.command" <<'EOF'
#!/bin/zsh
/usr/local/bin/pg27switch hdmi2
EOF

cat > "$LAUNCHERS_DIR/TypeC.command" <<'EOF'
#!/bin/zsh
/usr/local/bin/pg27switch usbc
EOF

chmod +x "$LAUNCHERS_DIR"/*.command

mkdir -p "$HOME/Library/Logs/PG27UCDMSwitcher"

echo "Installed $BIN"
echo "Launchers: $LAUNCHERS_DIR"
