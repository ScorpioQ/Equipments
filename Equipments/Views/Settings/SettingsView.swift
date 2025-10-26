//
//  SettingsView.swift
//  Equipments
//
//  Created by AI on 2024/11/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedLanguage") private var selectedLanguageValue = AppLanguage.system.rawValue
    @State private var lastSyncDate: Date? = nil
    @State private var isSyncing: Bool = false

    private var languageBinding: Binding<AppLanguage> {
        Binding(
            get: { AppLanguage.fromPersistedValue(selectedLanguageValue) },
            set: { selectedLanguageValue = $0.rawValue }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(Text("settings.section.language")) {
                    Picker("settings.language.picker", selection: languageBinding) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.localizedTitleKey).tag(language)
                        }
                    }
                    Text("settings.language.description")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section(Text("settings.section.sync")) {
                    if isSyncing {
                        ProgressView("settings.sync.in.progress")
                    } else {
                        Button("settings.sync.trigger") {
                            triggerSync()
                        }
                    }

                    if let lastSyncDate {
                        LabeledContent {
                            Text(lastSyncDate, format: .dateTime.year().month().day().hour().minute())
                        } label: {
                            Text("settings.sync.last")
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    } else {
                        Text("settings.sync.never")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("settings.navigation.title")
        }
    }

    private func triggerSync() {
        isSyncing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            lastSyncDate = Date()
            isSyncing = false
        }
    }
#Preview {
    SettingsView()
}
