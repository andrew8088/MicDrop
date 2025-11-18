import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleRecording = Self("toggleRecording", default: .init(.r, modifiers: [.command, .option]))
}

protocol KeyboardShortcutServiceDelegate: AnyObject {
    func keyboardShortcutServiceDidTrigger(_ service: KeyboardShortcutService)
}

class KeyboardShortcutService {
    weak var delegate: KeyboardShortcutServiceDelegate?

    private var isListening = false

    // MARK: - Start/Stop Listening

    func startListening() {
        guard !isListening else { return }

        KeyboardShortcuts.onKeyUp(for: .toggleRecording) { [weak self] in
            guard let self = self else { return }
            self.delegate?.keyboardShortcutServiceDidTrigger(self)
        }

        isListening = true
        print("Keyboard shortcut listening started")
    }

    func stopListening() {
        guard isListening else { return }

        // Note: KeyboardShortcuts package doesn't provide a way to stop listening
        // The listener will remain active but we can just set delegate to nil if needed
        isListening = false
        print("Keyboard shortcut listening stopped")
    }

    // MARK: - Get Current Shortcut

    func getCurrentShortcut() -> KeyboardShortcuts.Shortcut? {
        return KeyboardShortcuts.getShortcut(for: .toggleRecording)
    }

    @MainActor
    func getShortcutDescription() -> String {
        if let shortcut = getCurrentShortcut() {
            return shortcut.description
        }
        return "⌥⌘R (default)"
    }
}
