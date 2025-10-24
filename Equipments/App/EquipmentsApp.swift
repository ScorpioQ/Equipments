import SwiftUI
import CoreData

@main
struct EquipmentsApp: SwiftUI.App {
    @StateObject private var settingsStore = SettingsStore()
    private let persistenceController = PersistenceController.shared

    var body: some SwiftUI.Scene {
        SwiftUI.WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(settingsStore)
                .environment(\.locale, settingsStore.selectedLocale)
        }
    }
}
