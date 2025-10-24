import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settingsStore: SettingsStore

    @State private var showICloudRestartHint = false

    var body: some View {
        NavigationStack {
            Form {
                languageSection
                synchronizationSection
                aboutSection
            }
            .navigationTitle("settings.title")
            .alert("settings.icloud.restartTitle", isPresented: $showICloudRestartHint) {
                Button("common.ok", role: .cancel) { }
            } message: {
                Text("settings.icloud.restartMessage")
            }
        }
    }

    private var languageSection: some View {
        Section("settings.language.title") {
            Picker("settings.language.title", selection: $settingsStore.language) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.localizationKey)
                        .tag(language)
                }
            }
            .pickerStyle(.inline)
        }
    }

    private var synchronizationSection: some View {
        Section("settings.icloud.title") {
            Toggle(isOn: $settingsStore.iCloudSyncEnabled) {
                Text("settings.icloud.toggle")
            }
            .onChange(of: settingsStore.iCloudSyncEnabled) { _ in
                showICloudRestartHint = true
            }

            Text("settings.icloud.description")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var aboutSection: some View {
        Section("settings.about.title") {
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
               let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                LabeledContent("settings.about.version") {
                    Text("\(version) (\(build))")
                }
            }

            LabeledContent("settings.about.developer") {
                Text("settings.about.developerName")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsStore(preview: true))
}
