import SwiftUI
import KeyboardShortcuts

struct PreferencesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Preferences")
                .font(.title)
                .fontWeight(.bold)

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("Keyboard Shortcut")
                    .font(.headline)

                HStack {
                    Text("Toggle Recording:")
                        .frame(width: 140, alignment: .leading)

                    KeyboardShortcuts.Recorder(for: .toggleRecording)
                }

                Text("Press the shortcut combination you want to use")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("How to Use")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 4) {
                    Text("1. Press your keyboard shortcut to start recording")
                    Text("2. Speak your message")
                    Text("3. Press the shortcut again to stop and transcribe")
                    Text("4. The text will be pasted at your cursor location")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(20)
        .frame(width: 450, height: 300)
    }
}

#Preview {
    PreferencesView()
}
