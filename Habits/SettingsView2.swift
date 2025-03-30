import SwiftUI

struct SettingsView2: View {
    // Use @AppStorage to bind directly to UserDefaults
    @AppStorage(Constants.Settings.datesAppearReversedKey) private var datesAppearReversed: Bool = false // Default to false (Today on left)

    var body: some View {
        Form { 
            Section(header: Text("Display Options")) {
                Toggle("Show Oldest Dates First", isOn: $datesAppearReversed)
                Text("Controls the order of recent days shown in the main list.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Section {
                 Text("More settings coming soon inshaAllah")
            }
            Section {
                Text("Sufone Apps")
            }
        }
    }
}

struct SettingsView2_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
             SettingsView2()
                 .navigationTitle("Settings")
        }
    }
}
