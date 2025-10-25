import CoreData
import SwiftUI

final class PersistenceController {
    static let shared = PersistenceController()
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true, enableCloudKit: false)
        let context = controller.container.viewContext

        let defaultScene = Scene(context: context)
        defaultScene.id = UUID()
        defaultScene.name = "示例场景"
        defaultScene.createdAt = Date()

        for index in 0..<3 {
            let equipment = Equipment(context: context)
            equipment.id = UUID()
            equipment.name = "示例装备 \(index + 1)"
            equipment.price = 1999
            equipment.currencyCode = "CNY"
            equipment.purchaseDate = Calendar.current.date(byAdding: .day, value: -(index * 30 + 1), to: Date()) ?? Date()
            equipment.createdAt = Date()
            equipment.updatedAt = Date()
            equipment.scene = defaultScene
        }

        do {
            try context.save()
        } catch {
            assertionFailure("Failed to save preview data: \(error)")
        }

        return controller
    }()

    let container: NSPersistentCloudKitContainer

    private init(inMemory: Bool = false, enableCloudKit: Bool? = nil) {
        let useCloudKit: Bool
        if let enableCloudKit {
            useCloudKit = enableCloudKit
        } else {
            let userDefaultsValue = UserDefaults.standard.object(forKey: SettingsStore.Constants.iCloudKey)
            if userDefaultsValue != nil {
                useCloudKit = UserDefaults.standard.bool(forKey: SettingsStore.Constants.iCloudKey)
            } else {
                useCloudKit = true
            }
        }

        container = NSPersistentCloudKitContainer(name: "Equipments")

        let description: NSPersistentStoreDescription
        if let existingDescription = container.persistentStoreDescriptions.first {
            description = existingDescription
        } else {
            description = NSPersistentStoreDescription()
        }

        description.shouldAddStoreAsynchronously = false

        if inMemory {
            description.type = NSInMemoryStoreType
            description.url = URL(fileURLWithPath: "/dev/null")
        } else {
            description.type = NSSQLiteStoreType
            description.url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Equipments.sqlite")

            if useCloudKit {
                let options = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.example.Equipments")
                description.cloudKitContainerOptions = options
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            } else {
                description.cloudKitContainerOptions = nil
            }
        }

        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Unresolved error \(error)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.transactionAuthor = "main"
    }

    func save(context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            assertionFailure("Unresolved Core Data error: \(error)")
        }
    }
}
