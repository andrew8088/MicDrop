import Foundation
import AVFoundation
import Speech
import AppKit

class PermissionsManager {
    static let shared = PermissionsManager()

    private init() {}

    // MARK: - Microphone Permission

    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func checkMicrophonePermission() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        return status == .authorized
    }

    // MARK: - Speech Recognition Permission

    func requestSpeechRecognitionPermission(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }

    func checkSpeechRecognitionPermission() -> Bool {
        let status = SFSpeechRecognizer.authorizationStatus()
        return status == .authorized
    }

    // MARK: - Accessibility Permission

    func checkAccessibilityPermission() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        return AXIsProcessTrustedWithOptions(options)
    }

    func promptAccessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        _ = AXIsProcessTrustedWithOptions(options)
    }

    func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    // MARK: - Request All Permissions

    func requestAllPermissions(completion: @escaping (Bool) -> Void) {
        requestMicrophonePermission { micGranted in
            guard micGranted else {
                completion(false)
                return
            }

            self.requestSpeechRecognitionPermission { speechGranted in
                guard speechGranted else {
                    completion(false)
                    return
                }

                // Check accessibility (can't request programmatically)
                let accessibilityGranted = self.checkAccessibilityPermission()
                if !accessibilityGranted {
                    self.showAccessibilityAlert()
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }

    func checkAllPermissions() -> Bool {
        return checkMicrophonePermission() &&
               checkSpeechRecognitionPermission() &&
               checkAccessibilityPermission()
    }

    private func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "MicDrop needs Accessibility permission to paste transcribed text. Please enable it in System Settings."
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Later")
        alert.alertStyle = .warning

        if alert.runModal() == .alertFirstButtonReturn {
            openAccessibilitySettings()
        }
    }
}
