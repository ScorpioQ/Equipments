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

        let model = PersistenceController.makeManagedObjectModel()
        container = NSPersistentCloudKitContainer(name: "Equipments", managedObjectModel: model)

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            description.shouldAddStoreAsynchronously = false
            container.persistentStoreDescriptions = [description]
        } else {
            let description = NSPersistentStoreDescription()
            description.type = NSSQLiteStoreType
            description.shouldAddStoreAsynchronously = false
            description.url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Equipments.sqlite")

            if useCloudKit {
                let options = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.example.Equipments")
                description.cloudKitContainerOptions = options
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            }

            container.persistentStoreDescriptions = [description]
        }

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

private extension PersistenceController {
    static func makeManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let sceneEntity = NSEntityDescription()
        sceneEntity.name = "Scene"
        sceneEntity.managedObjectClassName = NSStringFromClass(Scene.self)

        let sceneId = NSAttributeDescription()
        sceneId.name = "id"
        sceneId.attributeType = .UUIDAttributeType
        sceneId.isOptional = false

        let sceneName = NSAttributeDescription()
        sceneName.name = "name"
        sceneName.attributeType = .stringAttributeType
        sceneName.isOptional = false

        let sceneCreatedAt = NSAttributeDescription()
        sceneCreatedAt.name = "createdAt"
        sceneCreatedAt.attributeType = .dateAttributeType
        sceneCreatedAt.isOptional = false

        let sceneColorHex = NSAttributeDescription()
        sceneColorHex.name = "colorHex"
        sceneColorHex.attributeType = .stringAttributeType
        sceneColorHex.isOptional = true

        sceneEntity.properties = [sceneId, sceneName, sceneCreatedAt, sceneColorHex]

        let equipmentEntity = NSEntityDescription()
        equipmentEntity.name = "Equipment"
        equipmentEntity.managedObjectClassName = NSStringFromClass(Equipment.self)

        let equipmentId = NSAttributeDescription()
        equipmentId.name = "id"
        equipmentId.attributeType = .UUIDAttributeType
        equipmentId.isOptional = false

        let equipmentName = NSAttributeDescription()
        equipmentName.name = "name"
        equipmentName.attributeType = .stringAttributeType
        equipmentName.isOptional = false

        let equipmentPrice = NSAttributeDescription()
        equipmentPrice.name = "price"
        equipmentPrice.attributeType = .doubleAttributeType
        equipmentPrice.isOptional = false
        equipmentPrice.defaultValue = 0

        let equipmentCurrency = NSAttributeDescription()
        equipmentCurrency.name = "currencyCode"
        equipmentCurrency.attributeType = .stringAttributeType
        equipmentCurrency.isOptional = true

        let equipmentPurchaseDate = NSAttributeDescription()
        equipmentPurchaseDate.name = "purchaseDate"
        equipmentPurchaseDate.attributeType = .dateAttributeType
        equipmentPurchaseDate.isOptional = false

        let equipmentCreatedAt = NSAttributeDescription()
        equipmentCreatedAt.name = "createdAt"
        equipmentCreatedAt.attributeType = .dateAttributeType
        equipmentCreatedAt.isOptional = false

        let equipmentUpdatedAt = NSAttributeDescription()
        equipmentUpdatedAt.name = "updatedAt"
        equipmentUpdatedAt.attributeType = .dateAttributeType
        equipmentUpdatedAt.isOptional = false

        let equipmentNotes = NSAttributeDescription()
        equipmentNotes.name = "notes"
        equipmentNotes.attributeType = .stringAttributeType
        equipmentNotes.isOptional = true

        let sceneRelationship = NSRelationshipDescription()
        sceneRelationship.name = "scene"
        sceneRelationship.destinationEntity = sceneEntity
        sceneRelationship.maxCount = 1
        sceneRelationship.minCount = 0
        sceneRelationship.deleteRule = .nullifyDeleteRule

        let equipmentRelationship = NSRelationshipDescription()
        equipmentRelationship.name = "equipments"
        equipmentRelationship.destinationEntity = equipmentEntity
        equipmentRelationship.minCount = 0
        equipmentRelationship.maxCount = 0
        equipmentRelationship.deleteRule = .cascadeDeleteRule

        sceneRelationship.inverseRelationship = equipmentRelationship
        equipmentRelationship.inverseRelationship = sceneRelationship

        equipmentEntity.properties = [
            equipmentId,
            equipmentName,
            equipmentPrice,
            equipmentCurrency,
            equipmentPurchaseDate,
            equipmentCreatedAt,
            equipmentUpdatedAt,
            equipmentNotes,
            sceneRelationship
        ]

        sceneEntity.properties.append(equipmentRelationship)

        model.entities = [sceneEntity, equipmentEntity]
        return model
    }
}
