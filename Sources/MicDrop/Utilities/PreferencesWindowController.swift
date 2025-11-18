import Cocoa
import SwiftUI

class PreferencesWindowController {
    private var window: NSWindow?

    func show() {
        if let window = window {
            // Window already exists, just bring it to front
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Create the SwiftUI view
        let preferencesView = PreferencesView()

        // Create the hosting controller
        let hostingController = NSHostingController(rootView: preferencesView)

        // Create the window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.center()
        window.title = "MicDrop Preferences"
        window.contentViewController = hostingController
        window.isReleasedWhenClosed = false
        window.level = .floating

        self.window = window

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func close() {
        window?.close()
    }
}
