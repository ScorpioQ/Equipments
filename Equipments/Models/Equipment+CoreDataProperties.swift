//
//  Equipment+CoreDataProperties.swift
//  Equipments
//
//  Created by AI on 2024/11/23.
//

import Foundation
import CoreData

public extension Equipment {
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<Equipment> {
        NSFetchRequest<Equipment>(entityName: "Equipment")
    }

    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var purchaseDate: Date?
    @NSManaged var purchasePrice: Double
    @NSManaged var isActive: Bool
    @NSManaged var notes: String?
    @NSManaged var imageData: Data?
    @NSManaged var createdAt: Date?
    @NSManaged var scene: Scene?
}

public extension Equipment {
    var wrappedID: UUID {
        if let id {
            return id
        }
        let newID = UUID()
        id = newID
        return newID
    }

    var wrappedName: String {
        get { name?.isEmpty == false ? name! : "未命名装备" }
        set { name = newValue }
    }

    var wrappedPurchaseDate: Date {
        get { purchaseDate ?? Date() }
        set { purchaseDate = newValue }
    }

    var heldDays: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: wrappedPurchaseDate)
        let end = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: start, to: end)
        return max(components.day ?? 0, 1)
    }

    var dailyCost: Double {
        guard heldDays > 0 else { return 0 }
        return purchasePrice / Double(heldDays)
    }
}

extension Equipment: Identifiable {}
