# Setup Guide for MicDrop

This guide covers how to build, package, and share MicDrop.

## Table of Contents

- [Building from Source](#building-from-source)
- [Creating a Standalone App](#creating-a-standalone-app)
- [Installing the App](#installing-the-app)
- [Sharing on GitHub](#sharing-on-github)
- [Distributing to Others](#distributing-to-others)

## Building from Source

### Prerequisites

- macOS 13.0 or later
- Xcode 15+ or Swift 5.9+
- Command Line Tools installed

### Quick Build

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/MicDrop.git
cd MicDrop

# Build and run
swift run
```

### Development Build

```bash
# Build in debug mode (faster compilation, includes debug symbols)
swift build

# Run the executable
.build/debug/MicDrop
```

### Release Build

```bash
# Build optimized release version
swift build -c release

# Run the release executable
.build/release/MicDrop
```

## Creating a Standalone App

To create a double-clickable `.app` bundle:

```bash
./build-app.sh
```

This creates `MicDrop.app` in the current directory.

### What the Build Script Does

1. Builds the project in release mode (optimized)
2. Creates a proper macOS app bundle structure
3. Copies the executable and Info.plist
4. Sets up all necessary bundle metadata

### Testing the App Bundle

```bash
# Run the app
open MicDrop.app

# Or double-click MicDrop.app in Finder
```

## Installing the App

### Option 1: Manual Installation

```bash
# Copy to Applications folder
cp -r MicDrop.app /Applications/

# Launch from Spotlight
# Press ⌘+Space and type "MicDrop"
```

### Option 2: Drag and Drop

1. Open Finder
2. Drag `MicDrop.app` to `/Applications`
3. Launch from Applications folder or Spotlight

### First Launch

On first launch, macOS may show a security warning because the app isn't code-signed. To run it:

1. Right-click (or Control+click) on MicDrop.app
2. Select "Open"
3. Click "Open" in the dialog that appears
4. The app will now run and remember this choice

## Sharing on GitHub

### Initial Setup

```bash
# Navigate to your project directory
cd MicDrop

# Initialize git (if not already done)
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: MicDrop macOS app"
```

### Create GitHub Repository

1. Go to [GitHub](https://github.com/new)
2. Create a new repository named `MicDrop`
3. **Don't** initialize with README (you already have one)

### Push to GitHub

```bash
# Add your GitHub repository as remote
git remote add origin https://github.com/YOUR_USERNAME/MicDrop.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### What Gets Shared

Thanks to `.gitignore`, these files are **excluded**:
- Build artifacts (`.build/`, `*.app`)
- Xcode user data
- macOS system files (`.DS_Store`)
- IDE files

These files **are included**:
- All source code
- `Package.swift` (dependencies)
- `README.md` (documentation)
- `LICENSE` (MIT license)
- `build-app.sh` (build script)
- `.gitignore`

## Distributing to Others

### For Developers

Share your GitHub repository URL:
```
https://github.com/YOUR_USERNAME/MicDrop
```

Users can then:
```bash
git clone https://github.com/YOUR_USERNAME/MicDrop.git
cd MicDrop
./build-app.sh
open MicDrop.app
```

### For End Users (Non-Developers)

#### Option 1: GitHub Releases (Recommended)

1. Build the app:
   ```bash
   ./build-app.sh
   ```

2. Create a zip file:
   ```bash
   ditto -c -k --sequesterRsrc --keepParent MicDrop.app MicDrop.zip
   ```

3. Create a GitHub Release:
   - Go to your repository on GitHub
   - Click "Releases" → "Create a new release"
   - Tag version (e.g., `v1.0.0`)
   - Upload `MicDrop.zip`
   - Write release notes
   - Publish release

Users can then download the zip, extract, and run the app.

#### Option 2: Direct Distribution

1. Build and zip the app:
   ```bash
   ./build-app.sh
   ditto -c -k --sequesterRsrc --keepParent MicDrop.app MicDrop.zip
   ```

2. Share the zip file via:
   - Email
   - Cloud storage (Dropbox, Google Drive, etc.)
   - File transfer service

### Important Notes for Distribution

⚠️ **Code Signing**: The app is not code-signed, so users will need to:
- Right-click → Open (first time only)
- Or disable Gatekeeper temporarily (not recommended)

For wider distribution, consider:
- Getting an Apple Developer account ($99/year)
- Code signing the app
- Notarizing the app
- Distributing via Mac App Store

## Advanced: Code Signing (Optional)

If you have an Apple Developer account:

```bash
# Sign the app
codesign --force --deep --sign "Developer ID Application: Your Name" MicDrop.app

# Verify signature
codesign --verify --deep --strict MicDrop.app

# Notarize (required for macOS 10.15+)
# Follow Apple's notarization guide
```

## Continuous Integration

### GitHub Actions (Optional)

Create `.github/workflows/build.yml`:

```yaml
name: Build

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: swift build -c release
      - name: Test
        run: swift test  # if you add tests
```

## Troubleshooting

### Build Fails

```bash
# Clean build artifacts
rm -rf .build/
swift package clean

# Rebuild
swift build
```

### App Won't Open

- Check macOS security settings
- Try right-click → Open
- Check Console.app for error messages

### Permissions Not Working

- Ensure Info.plist has all permission descriptions
- Rebuild the app bundle
- Check System Settings → Privacy & Security

## Next Steps

- Add tests with `swift test`
- Set up CI/CD with GitHub Actions
- Get Apple Developer account for code signing
- Submit to Mac App Store
- Add automatic updates (Sparkle framework)

## Support

- Open an issue on GitHub
- Check existing issues
- Read the README.md for usage help
