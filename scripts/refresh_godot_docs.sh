#!/usr/bin/env bash

set -e

DOCS_DIR="docs"
TARGET_DIR="$DOCS_DIR/godot"
TMP_ZIP="godot-docs.zip"
URL="https://github.com/godotengine/godot-docs/archive/refs/heads/4.6.zip"

echo "Refreshing Godot 4.6 docs..."

mkdir -p "$DOCS_DIR"

if [ -d "$TARGET_DIR" ]; then
    echo "Removing old docs..."
    rm -rf "$TARGET_DIR"
fi

echo "Downloading..."
wget -q "$URL" -O "$TMP_ZIP"

echo "Extracting..."
unzip -q "$TMP_ZIP"

# Detect extracted folder name dynamically
EXTRACTED_DIR=$(unzip -Z1 "$TMP_ZIP" | head -n1 | cut -d/ -f1)

mv "$EXTRACTED_DIR" "$TARGET_DIR"

# Prevent Godot from importing docs
touch "$TARGET_DIR/.gdignore"

rm "$TMP_ZIP"

echo "Godot 4.6 docs refreshed successfully!"