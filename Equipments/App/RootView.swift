import SwiftUI

struct RootView: View {
    @EnvironmentObject private var settingsStore: SettingsStore

    var body: some View {
        TabView(selection: $settingsStore.selectedTab) {
            EquipmentListView()
                .tabItem {
                    Label("tab.equipments", systemImage: "shippingbox")
                }
                .tag(AppTab.equipments)

            SceneListView()
                .tabItem {
                    Label("tab.scenes", systemImage: "square.grid.2x2")
                }
                .tag(AppTab.scenes)

            SettingsView()
                .tabItem {
                    Label("tab.settings", systemImage: "gear")
                }
                .tag(AppTab.settings)
        }
    }
}

#Preview {
    RootView()
        .environmentObject(SettingsStore(preview: true))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
