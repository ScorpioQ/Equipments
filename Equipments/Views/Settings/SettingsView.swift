//
//  SettingsView.swift
//  Equipments
//
//  Created by AI on 2024/11/23.
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedLanguage: AppLanguage = .system
    @State private var lastSyncDate: Date? = nil
    @State private var isSyncing: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("语言") {
                    Picker("应用语言", selection: $selectedLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    Text("语言切换功能将在后续迭代中接入实际多语言资源。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("iCloud 同步") {
                    if isSyncing {
                        ProgressView("正在同步…")
                    } else {
                        Button("手动触发同步") {
                            triggerSync()
                        }
                    }

                    if let lastSyncDate {
                        Text("最后同步时间：\(lastSyncDate.formatted(date: .abbreviated, time: .shortened))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("尚未同步")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
        }
    }

    private func triggerSync() {
        isSyncing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            lastSyncDate = Date()
            isSyncing = false
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case simplifiedChinese
    case traditionalChinese
    case english

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:
            return "跟随系统"
        case .simplifiedChinese:
            return "简体中文"
        case .traditionalChinese:
            return "繁體中文"
        case .english:
            return "English"
        }
    }
}

#Preview {
    SettingsView()
}
