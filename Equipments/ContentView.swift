//
//  RootView.swift
//  Equipments
//
//  Created by 米樵 on 2024/11/22.
//

import SwiftUI

struct RootView: View {
    @AppStorage("selectedLanguage") private var selectedLanguageValue = AppLanguage.system.rawValue

    private var selectedLanguage: AppLanguage {
        AppLanguage.fromPersistedValue(selectedLanguageValue)
    }

    private var selectedLocale: Locale {
        selectedLanguage.locale ?? .autoupdatingCurrent
    }

    var body: some View {
        TabView {
            SceneListView()
                .tabItem {
                    Label("tab.scenes", systemImage: "rectangle.3.group")
                }

            SettingsView()
                .tabItem {
                    Label("tab.settings", systemImage: "gearshape")
                }
        }
        .environment(\.locale, selectedLocale)
    }
}

#Preview {
    RootView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
