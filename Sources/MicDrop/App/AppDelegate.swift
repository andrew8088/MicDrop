import Cocoa
import AppKit
import AVFoundation
import Speech

enum AppState {
    case idle
    case recording
    case transcribing
}

class AppDelegate: NSObject, NSApplicationDelegate {
    // Menu bar
    private var statusItem: NSStatusItem!
    private var menu: NSMenu!

    // Services
    private let audioRecordingService = AudioRecordingService()
    private let speechRecognitionService = SpeechRecognitionService()
    private let keyboardShortcutService = KeyboardShortcutService()
    private let permissionsManager = PermissionsManager.shared
    private let pasteService = PasteService.shared
    private let preferencesWindowController = PreferencesWindowController()

    // State
    private var appState: AppState = .idle {
        didSet {
            updateMenuBarIcon()
        }
    }
    private var transcribedText: String = ""

    // MARK: - Application Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set up menu bar
        setupMenuBar()

        // Set up delegates
        audioRecordingService.delegate = self
        speechRecognitionService.delegate = self
        keyboardShortcutService.delegate = self

        // Request permissions
        requestPermissions()

        // Start listening for keyboard shortcut
        keyboardShortcutService.startListening()

        print("MicDrop started")
        print("Press ⌥⌘R to toggle recording")
    }

    func applicationWillTerminate(_ notification: Notification) {
        if appState == .recording {
            stopRecording()
        }
    }

    // MARK: - Menu Bar Setup

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "mic", accessibilityDescription: "MicDrop")
        }

        menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Status: Idle", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(openPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Check Permissions", action: #selector(checkPermissions), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    private func updateMenuBarIcon() {
        guard let button = statusItem.button else { return }

        DispatchQueue.main.async {
            switch self.appState {
            case .idle:
                button.image = NSImage(systemSymbolName: "mic", accessibilityDescription: "MicDrop")
                self.updateStatusMenuItem("Idle")
            case .recording:
                button.image = NSImage(systemSymbolName: "mic.fill", accessibilityDescription: "Recording")
                self.updateStatusMenuItem("Recording...")
            case .transcribing:
                button.image = NSImage(systemSymbolName: "waveform", accessibilityDescription: "Transcribing")
                self.updateStatusMenuItem("Transcribing...")
            }
        }
    }

    private func updateStatusMenuItem(_ status: String) {
        if let item = menu.item(at: 0) {
            item.title = "Status: \(status)"
        }
    }

    // MARK: - Permissions

    private func requestPermissions() {
        permissionsManager.requestAllPermissions { granted in
            if granted {
                print("All permissions granted")
            } else {
                print("Some permissions were not granted")
                self.showPermissionsAlert()
            }
        }
    }

    @objc private func checkPermissions() {
        let micGranted = permissionsManager.checkMicrophonePermission()
        let speechGranted = permissionsManager.checkSpeechRecognitionPermission()
        let accessibilityGranted = permissionsManager.checkAccessibilityPermission()

        let alert = NSAlert()
        alert.messageText = "Permissions Status"
        alert.informativeText = """
        Microphone: \(micGranted ? "✓" : "✗")
        Speech Recognition: \(speechGranted ? "✓" : "✗")
        Accessibility: \(accessibilityGranted ? "✓" : "✗")

        All permissions are required for the app to function properly.
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")

        if !accessibilityGranted {
            alert.addButton(withTitle: "Open System Settings")
        }

        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            permissionsManager.openAccessibilitySettings()
        }
    }

    private func showPermissionsAlert() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Permissions Required"
            alert.informativeText = "MicDrop needs microphone, speech recognition, and accessibility permissions to work. Please grant them in System Settings."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }

    // MARK: - Recording Control

    private func toggleRecording() {
        switch appState {
        case .idle:
            startRecording()
        case .recording:
            stopRecording()
        case .transcribing:
            print("Currently transcribing, please wait...")
        }
    }

    private func startRecording() {
        // Check permissions
        guard permissionsManager.checkAllPermissions() else {
            showPermissionsAlert()
            return
        }

        // Start speech recognition
        do {
            try speechRecognitionService.startRecognition()
        } catch {
            showError("Failed to start speech recognition: \(error.localizedDescription)")
            return
        }

        // Start audio recording
        do {
            try audioRecordingService.startRecording()
        } catch {
            speechRecognitionService.stopRecognition()
            showError("Failed to start audio recording: \(error.localizedDescription)")
            return
        }

        appState = .recording
        transcribedText = ""
        print("Recording started")
    }

    private func stopRecording() {
        // Stop audio recording
        audioRecordingService.stopRecording()

        // Stop speech recognition (will wait for final results)
        speechRecognitionService.stopRecognition()

        appState = .transcribing
        print("Recording stopped, transcribing...")
    }

    // MARK: - Paste

    private func pasteTranscribedText() {
        guard !transcribedText.isEmpty else {
            print("No text to paste")
            appState = .idle
            return
        }

        print("Pasting text: \(transcribedText)")

        // Small delay to allow user to focus the target app
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let success = self.pasteService.pasteText(self.transcribedText)

            if success {
                print("Text pasted successfully")
            } else {
                print("Failed to paste text")
                self.showError("Failed to paste text. Make sure accessibility permission is granted.")
            }

            self.appState = .idle
        }
    }

    // MARK: - Error Handling

    private func showError(_ message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.informativeText = message
            alert.alertStyle = .critical
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }

    // MARK: - Menu Actions

    @objc private func openPreferences() {
        preferencesWindowController.show()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - AudioRecordingServiceDelegate

extension AppDelegate: AudioRecordingServiceDelegate {
    func audioRecordingService(_ service: AudioRecordingService, didReceiveBuffer buffer: AVAudioPCMBuffer, time: AVAudioTime) {
        // Forward audio buffer to speech recognition
        speechRecognitionService.appendAudioBuffer(buffer)
    }

    func audioRecordingServiceDidFinishRecording(_ service: AudioRecordingService) {
        print("Audio recording finished")
    }
}

// MARK: - SpeechRecognitionServiceDelegate

extension AppDelegate: SpeechRecognitionServiceDelegate {
    func speechRecognitionService(_ service: SpeechRecognitionService, didRecognizeText text: String, isFinal: Bool) {
        print("Recognized text (\(isFinal ? "final" : "partial")): \(text)")

        // Only update if we have text, to preserve the last good partial result
        if !text.isEmpty {
            transcribedText = text
        }

        if isFinal {
            // Final transcription received, paste it
            pasteTranscribedText()
        }
    }

    func speechRecognitionService(_ service: SpeechRecognitionService, didFailWithError error: Error) {
        print("Speech recognition error: \(error.localizedDescription)")

        // If we have any transcribed text, try to paste it anyway
        if !transcribedText.isEmpty {
            print("Attempting to paste partial transcription despite error")
            pasteTranscribedText()
        } else {
            // Only show error if we have nothing to paste
            showError("Speech recognition failed: \(error.localizedDescription)")
            appState = .idle
        }
    }
}

// MARK: - KeyboardShortcutServiceDelegate

extension AppDelegate: KeyboardShortcutServiceDelegate {
    func keyboardShortcutServiceDidTrigger(_ service: KeyboardShortcutService) {
        print("Keyboard shortcut triggered")
        toggleRecording()
    }
}
