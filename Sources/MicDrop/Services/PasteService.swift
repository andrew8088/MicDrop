import Foundation
import AppKit
import CoreGraphics

class PasteService {
    static let shared = PasteService()

    private init() {}

    // MARK: - Paste Text

    func pasteText(_ text: String) -> Bool {
        // Check accessibility permission
        guard PermissionsManager.shared.checkAccessibilityPermission() else {
            print("Accessibility permission not granted")
            return false
        }

        // Copy text to pasteboard
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        // Small delay to ensure pasteboard is ready
        usleep(50_000) // 50ms

        // Simulate Command+V keypress
        return simulateCommandV()
    }

    // MARK: - Simulate Command+V

    private func simulateCommandV() -> Bool {
        let vKeyCode: CGKeyCode = 0x09 // V key

        // Create keydown event with Command modifier
        guard let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: vKeyCode, keyDown: true) else {
            print("Failed to create keydown event")
            return false
        }
        keyDownEvent.flags = .maskCommand

        // Create keyup event with Command modifier
        guard let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: vKeyCode, keyDown: false) else {
            print("Failed to create keyup event")
            return false
        }
        keyUpEvent.flags = .maskCommand

        // Post events
        keyDownEvent.post(tap: .cghidEventTap)
        keyUpEvent.post(tap: .cghidEventTap)

        print("Paste command sent successfully")
        return true
    }

    // MARK: - Alternative: Type Text Directly (slower but more reliable in some cases)

    func typeText(_ text: String) -> Bool {
        guard PermissionsManager.shared.checkAccessibilityPermission() else {
            print("Accessibility permission not granted")
            return false
        }

        for character in text {
            if !typeCharacter(character) {
                return false
            }
            usleep(10_000) // 10ms delay between characters
        }

        return true
    }

    private func typeCharacter(_ character: Character) -> Bool {
        // Get keycode and modifier for character
        guard let (keyCode, flags) = getKeyCodeForCharacter(character) else {
            print("Unable to get keycode for character: \(character)")
            return false
        }

        // Create and post keydown event
        guard let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true) else {
            return false
        }
        keyDownEvent.flags = flags

        // Create and post keyup event
        guard let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false) else {
            return false
        }
        keyUpEvent.flags = flags

        keyDownEvent.post(tap: .cghidEventTap)
        keyUpEvent.post(tap: .cghidEventTap)

        return true
    }

    // MARK: - Character to KeyCode Mapping

    private func getKeyCodeForCharacter(_ character: Character) -> (CGKeyCode, CGEventFlags)? {
        let charString = String(character).lowercased()
        let needsShift = character.isUppercase || "!@#$%^&*()_+{}|:\"<>?".contains(character)

        let keyCode: CGKeyCode?

        switch charString {
        // Letters
        case "a": keyCode = 0x00
        case "b": keyCode = 0x0B
        case "c": keyCode = 0x08
        case "d": keyCode = 0x02
        case "e": keyCode = 0x0E
        case "f": keyCode = 0x03
        case "g": keyCode = 0x05
        case "h": keyCode = 0x04
        case "i": keyCode = 0x22
        case "j": keyCode = 0x26
        case "k": keyCode = 0x28
        case "l": keyCode = 0x25
        case "m": keyCode = 0x2E
        case "n": keyCode = 0x2D
        case "o": keyCode = 0x1F
        case "p": keyCode = 0x23
        case "q": keyCode = 0x0C
        case "r": keyCode = 0x0F
        case "s": keyCode = 0x01
        case "t": keyCode = 0x11
        case "u": keyCode = 0x20
        case "v": keyCode = 0x09
        case "w": keyCode = 0x0D
        case "x": keyCode = 0x07
        case "y": keyCode = 0x10
        case "z": keyCode = 0x06

        // Numbers
        case "0", ")": keyCode = 0x1D
        case "1", "!": keyCode = 0x12
        case "2", "@": keyCode = 0x13
        case "3", "#": keyCode = 0x14
        case "4", "$": keyCode = 0x15
        case "5", "%": keyCode = 0x17
        case "6", "^": keyCode = 0x16
        case "7", "&": keyCode = 0x1A
        case "8", "*": keyCode = 0x1C
        case "9", "(": keyCode = 0x19

        // Special characters
        case " ": keyCode = 0x31  // Space
        case "\n", "\r": keyCode = 0x24  // Return
        case "\t": keyCode = 0x30  // Tab
        case "-", "_": keyCode = 0x1B
        case "=", "+": keyCode = 0x18
        case "[", "{": keyCode = 0x21
        case "]", "}": keyCode = 0x1E
        case "\\", "|": keyCode = 0x2A
        case ";", ":": keyCode = 0x29
        case "'", "\"": keyCode = 0x27
        case ",", "<": keyCode = 0x2B
        case ".", ">": keyCode = 0x2F
        case "/", "?": keyCode = 0x2C
        case "`", "~": keyCode = 0x32

        default:
            return nil
        }

        guard let code = keyCode else {
            return nil
        }

        let flags: CGEventFlags = needsShift ? .maskShift : []
        return (code, flags)
    }
}
