#!/bin/bash
set -e

echo "Building MicDrop..."

# Build for release
swift build -c release

# Create app bundle structure
APP_NAME="MicDrop"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS="${APP_BUNDLE}/Contents"
MACOS="${CONTENTS}/MacOS"
RESOURCES="${CONTENTS}/Resources"

echo "Creating app bundle structure..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${MACOS}"
mkdir -p "${RESOURCES}"

# Copy executable
echo "Copying executable..."
cp ".build/release/${APP_NAME}" "${MACOS}/"

# Copy Info.plist
echo "Copying Info.plist..."
cp "Sources/MicDrop/Info.plist" "${CONTENTS}/"

# Update Info.plist with bundle identifier and executable name
/usr/libexec/PlistBuddy -c "Set :CFBundleExecutable ${APP_NAME}" "${CONTENTS}/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.micdrop.app" "${CONTENTS}/Info.plist" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string com.micdrop.app" "${CONTENTS}/Info.plist"

echo ""
echo "✅ Build complete!"
echo "📦 App bundle created at: ${APP_BUNDLE}"
echo ""
echo "To run the app:"
echo "  open ${APP_BUNDLE}"
echo ""
echo "To install to Applications folder:"
echo "  cp -r ${APP_BUNDLE} /Applications/"
echo ""
