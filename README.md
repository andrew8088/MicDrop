# MicDrop

A macOS menu bar application that allows you to record your voice with a keyboard shortcut, transcribe it using the Speech framework, and paste the transcribed text wherever your cursor is.

## Features

- Customizable global keyboard shortcut (default: ⌥⌘R) to toggle recording
- Real-time speech recognition using macOS Speech framework
- On-device transcription support for privacy
- Automatic pasting at cursor location
- Menu bar integration with status indicators
- Permission management for microphone, speech recognition, and accessibility
- Easy-to-use Preferences window

## Requirements

- macOS 13.0 or later
- Xcode or Swift Package Manager
- Microphone access
- Speech recognition permission
- Accessibility permission (for pasting)

## Building & Installation

### Quick Start (Development)

```bash
# Build and run
swift run
```

### Create a Standalone App

```bash
# Build a double-clickable .app bundle
./build-app.sh

# Install to Applications folder
cp -r MicDrop.app /Applications/
```

### For Developers

**Development Mode:**
```bash
swift build          # Debug build
swift run            # Build and run
```

**Release Mode:**
```bash
swift build -c release
.build/release/MicDrop
```

**Using Xcode:**
1. Open Package.swift in Xcode
2. Build and run the project (⌘R)

📖 See [SETUP.md](SETUP.md) for detailed build, packaging, and distribution instructions.

## Setup

### Required Permissions

The app requires three permissions to function:

1. **Microphone** - To record your voice
2. **Speech Recognition** - To transcribe the audio
3. **Accessibility** - To paste text at cursor location

On first launch, the app will request microphone and speech recognition permissions. For accessibility permission, you'll need to:

1. Open System Settings
2. Go to Privacy & Security > Accessibility
3. Enable MicDrop in the list

You can check permission status anytime by clicking the menu bar icon and selecting "Check Permissions".

## Usage

1. Launch the app - it will appear in your menu bar as a microphone icon
2. Press **⌥⌘R** (Option+Command+R) to start recording
   - The menu bar icon changes to a filled microphone
3. Speak your message
4. Press **⌥⌘R** again to stop recording
   - The app will transcribe your speech
   - The menu bar icon changes to a waveform
5. The transcribed text is automatically pasted at your cursor location

## Menu Bar

Click the menu bar icon to see:
- Current status (Idle, Recording, or Transcribing)
- Preferences (⌘,) - Customize your keyboard shortcut
- Permission checker
- Quit option

## Architecture

The app is built with a clean service-oriented architecture:

- **AudioRecordingService** - Manages audio recording using AVAudioEngine
- **SpeechRecognitionService** - Handles speech-to-text using SFSpeechRecognizer
- **PasteService** - Simulates paste events using CGEvent
- **KeyboardShortcutService** - Manages global keyboard shortcuts
- **PermissionsManager** - Handles all permission requests and checks
- **AppDelegate** - Coordinates all services and manages app state

## Customization

### Changing the Keyboard Shortcut

The default shortcut is ⌥⌘R (Option+Command+R). To customize it:

1. Click the menu bar icon
2. Select "Preferences..." (or press ⌘,)
3. Click on the keyboard shortcut recorder
4. Press your desired key combination
5. The new shortcut is saved automatically

Your custom shortcut will persist across app restarts.

### On-Device vs Server Recognition

By default, the app uses on-device speech recognition for privacy. To force server-based recognition (more accurate but requires internet), modify `SpeechRecognitionService.swift`:

```swift
private var useOnDeviceRecognition = false
```

## Troubleshooting

### App doesn't respond to keyboard shortcut
- Make sure the app is running (check menu bar)
- Verify another app isn't using the same shortcut
- Try changing the shortcut in Preferences if there's a conflict
- Try relaunching the app

### Pasting doesn't work
- Open System Settings > Privacy & Security > Accessibility
- Make sure MicDrop is enabled
- You may need to remove and re-add it

### Speech recognition fails
- Check your internet connection (if using server-based recognition)
- Ensure speech recognition permission is granted
- Try speaking more clearly or in a quieter environment

### Poor transcription quality
- Speak clearly and at a moderate pace
- Reduce background noise
- For better accuracy, consider using server-based recognition (requires internet)

## Privacy

- When using on-device recognition, your voice data never leaves your Mac
- Server-based recognition sends audio to Apple servers
- The app does not store any recordings or transcriptions
- All transcribed text is immediately pasted and cleared from memory

## Dependencies

- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) - For global keyboard shortcut support

## License

MIT License - Feel free to modify and distribute as needed.

## Credits

Built using macOS Speech framework, AVFoundation, and Core Graphics.
