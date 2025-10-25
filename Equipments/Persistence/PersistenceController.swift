//
//  PersistenceController.swift
//  Equipments
//
//  Created by AI on 2024/11/23.
//

import CoreData

/// 管理 Core Data 与 CloudKit 容器的单例控制器。
struct PersistenceController {
    static let shared = PersistenceController()

    /// 预览环境使用的内存容器，内置示例数据以供 SwiftUI 预览。
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        let basketball = EquipmentScene(context: context)
        basketball.id = UUID()
        basketball.name = "篮球装备"
        basketball.summary = "打球必备"
        basketball.createdAt = Date()

        let shoes = Equipment(context: context)
        shoes.id = UUID()
        shoes.name = "篮球鞋"
        shoes.purchaseDate = Calendar.current.date(byAdding: .day, value: -120, to: Date()) ?? Date()
        shoes.purchasePrice = 1299
        shoes.isActive = true
        shoes.notes = "夏季比赛穿着"
        shoes.scene = basketball
        shoes.createdAt = Date()

        let ball = Equipment(context: context)
        ball.id = UUID()
        ball.name = "比赛用球"
        ball.purchaseDate = Calendar.current.date(byAdding: .day, value: -200, to: Date()) ?? Date()
        ball.purchasePrice = 399
        ball.isActive = true
        ball.scene = basketball
        ball.createdAt = Date()

        context.saveIfNeeded()
        return controller
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Equipments")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Missing persistent store description")
        }

        let cloudKitOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.Equipments")
        description.cloudKitContainerOptions = cloudKitOptions
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

}
