#!/bin/bash

# Rebuild script for React Native Godot project
# This script ensures all Godot changes are properly bundled and the app is rebuilt

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_PROJECT="$PROJECT_DIR/project"
IOS_DIR="$PROJECT_DIR/ios"
GODOT_APP="/Applications/Godot.app/Contents/MacOS/Godot"

echo "🔄 React Native Godot - Full Rebuild"
echo "======================================"

# Step 1: Export Godot project to .pck
echo ""
echo "📦 Step 1: Exporting Godot project to .pck..."
if [ -f "$GODOT_APP" ]; then
    "$GODOT_APP" --headless --export-pack "iOS" "$IOS_DIR/GodotTest.pck" --path "$GODOT_PROJECT/"
    echo "✅ Godot package exported successfully!"
else
    echo "❌ Error: Godot not found at $GODOT_APP"
    exit 1
fi

# Step 2: Clean Xcode derived data
echo ""
echo "🧹 Step 2: Cleaning Xcode cache..."
rm -rf ~/Library/Developer/Xcode/DerivedData/GodotTest-*
rm -rf "$IOS_DIR/build"
echo "✅ Xcode cache cleaned!"

# Step 3: Reinstall pods
echo ""
echo "📱 Step 3: Reinstalling CocoaPods..."
cd "$IOS_DIR"
pod install
cd "$PROJECT_DIR"
echo "✅ Pods reinstalled!"

# Step 4: Run on iOS simulator
echo ""
echo "🚀 Step 4: Building and running on iOS simulator..."
npx react-native run-ios --simulator="iPhone 16 Pro"

echo ""
echo "======================================"
echo "✅ Full rebuild complete!"
