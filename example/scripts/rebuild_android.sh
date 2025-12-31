#!/bin/bash

# Rebuild script for React Native Godot project (Android)
# This script ensures all Godot changes are properly bundled and the app is rebuilt

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_PROJECT="$PROJECT_DIR/project"
ANDROID_DIR="$PROJECT_DIR/android"
ASSETS_DIR="$ANDROID_DIR/app/src/main/assets"
GODOT_APP="/Applications/Godot.app/Contents/MacOS/Godot"

echo "🔄 React Native Godot - Full Rebuild (Android)"
echo "=============================================="

# Step 1: Export Godot project to .pck
echo ""
echo "📦 Step 1: Exporting Godot project to .pck..."
mkdir -p "$ASSETS_DIR"
if [ -f "$GODOT_APP" ]; then
    # Note: Using "Android" preset. 
    # Important: The output file usually matches what the JS code expects. 
    # App.tsx looks for "/GodotTest" path. 
    # Standard practice: export as 'game.pck' or similar. 
    # But since App.tsx has specific logic, checking initGodot('GodotTest'). 
    # On Android it passes --path /GodotTest. 
    # This might imply GodotTest is a directory or a resource pack.
    # We will export as GodotTest.pck for now.
    "$GODOT_APP" --headless --export-pack "Android" "$ASSETS_DIR/GodotTest.pck" --path "$GODOT_PROJECT/"
    echo "✅ Godot package exported successfully!"
else
    echo "❌ Error: Godot not found at $GODOT_APP"
    exit 1
fi

# Step 2: Clean Gradle
echo ""
echo "🧹 Step 2: Cleaning Gradle..."
cd "$ANDROID_DIR"
./gradlew clean
cd "$PROJECT_DIR"
echo "✅ Gradle cleaned!"

# Step 3: Run on Android
echo ""
echo "🚀 Step 3: Building and running on Android..."
npx react-native run-android

echo ""
echo "======================================"
echo "✅ Full Android rebuild complete!"
