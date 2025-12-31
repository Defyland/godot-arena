---
description: Full rebuild of React Native Godot project with fresh Godot package
---

# React Native Godot - Full Rebuild

This workflow completely rebuilds the project, ensuring all Godot changes are properly applied.

## Steps

// turbo-all

1. Export the Godot project to .pck package:
```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --export-pack "iOS" /Users/allanflavio/Documents/projects/PERSONAL/react-native-godot/example/ios/GodotTest.pck --path /Users/allanflavio/Documents/projects/PERSONAL/react-native-godot/example/project/
```

2. Clean Xcode derived data and build folders:
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/GodotTest-* /Users/allanflavio/Documents/projects/PERSONAL/react-native-godot/example/ios/build
```

3. Reinstall CocoaPods:
```bash
cd /Users/allanflavio/Documents/projects/PERSONAL/react-native-godot/example/ios && pod install
```

4. Build and run on iOS simulator:
```bash
cd /Users/allanflavio/Documents/projects/PERSONAL/react-native-godot/example && npx react-native run-ios --simulator="iPhone 16 Pro"
```

## Quick One-Liner

Run the rebuild script:
```bash
./scripts/rebuild.sh
```

## Notes

- The Godot project files are in `project/` folder
- The compiled `.pck` file is in `ios/GodotTest.pck`
- Changes to `.gd` or `.tscn` files require re-exporting the `.pck` file
- The Metro bundler should be running (`yarn start`) before running the app
