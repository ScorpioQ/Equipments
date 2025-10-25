//
//  EquipmentScene+CoreDataProperties.swift
//  Equipments
//
//  Created by AI on 2024/11/23.
//

import Foundation
import CoreData

public extension EquipmentScene {
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<EquipmentScene> {
        NSFetchRequest<EquipmentScene>(entityName: "EquipmentScene")
    }

    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var summary: String?
    @NSManaged var icon: String?
    @NSManaged var createdAt: Date?
    @NSManaged var equipments: NSSet?
}

public extension EquipmentScene {
    var wrappedID: UUID {
        if let id {
            return id
        }
        let newID = UUID()
        id = newID
        return newID
    }

    var wrappedName: String {
        get { name?.isEmpty == false ? name! : "未命名场景" }
        set { name = newValue }
    }

    var equipmentsArray: [Equipment] {
        let set = equipments as? Set<Equipment> ?? []
        return set.sorted { lhs, rhs in
            lhs.purchaseDate ?? .distantPast > rhs.purchaseDate ?? .distantPast
        }
    }

    var totalInvestment: Double {
        equipmentsArray.reduce(0) { $0 + $1.purchasePrice }
    }

    var averageDailyCost: Double {
        let costs = equipmentsArray.map { $0.dailyCost }
        guard costs.isEmpty == false else { return 0 }
        return costs.reduce(0, +) / Double(costs.count)
    }

    var activeEquipmentCount: Int {
        equipmentsArray.filter { $0.isActive }.count
    }
}

// MARK: Generated accessors for equipments
public extension EquipmentScene {
    @objc(addEquipmentsObject:)
    @NSManaged func addToEquipments(_ value: Equipment)

    @objc(removeEquipmentsObject:)
    @NSManaged func removeFromEquipments(_ value: Equipment)

    @objc(addEquipments:)
    @NSManaged func addToEquipments(_ values: NSSet)

    @objc(removeEquipments:)
    @NSManaged func removeFromEquipments(_ values: NSSet)
}

extension EquipmentScene: Identifiable {}
