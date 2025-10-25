import SwiftUI

@main
struct EquipmentsApp: App {
    @StateObject private var settingsStore = SettingsStore()
    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(settingsStore)
                .environment(\.locale, settingsStore.selectedLocale)
        }
    }
}
