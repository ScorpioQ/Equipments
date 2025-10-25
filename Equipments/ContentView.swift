//
//  RootView.swift
//  Equipments
//
//  Created by 米樵 on 2024/11/22.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            SceneListView()
                .tabItem {
                    Label("场景", systemImage: "rectangle.3.group")
                }

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    RootView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
