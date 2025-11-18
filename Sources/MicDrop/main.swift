import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Set activation policy to accessory to make it a menu bar app
app.setActivationPolicy(.accessory)

// Run the app
app.run()
