#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
OUTPUT="$BUILD_DIR/pg27switch"
MODULE_CACHE="$BUILD_DIR/module-cache"
ARCH="${ARCH:-$(uname -m)}"
MACOS_TARGET="${MACOS_TARGET:-12.0}"

mkdir -p "$BUILD_DIR"
mkdir -p "$MODULE_CACHE"

xcrun swiftc \
  -target "$ARCH-apple-macos$MACOS_TARGET" \
  -module-cache-path "$MODULE_CACHE" \
  -O \
  -framework AppKit \
  "$ROOT_DIR"/macos/Sources/*.swift \
  -o "$OUTPUT"

chmod +x "$OUTPUT"
echo "$OUTPUT"
