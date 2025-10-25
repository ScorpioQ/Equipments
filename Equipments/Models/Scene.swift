import CoreData
import Foundation

@objc(Scene)
public class Scene: NSManagedObject {
}

public extension Scene {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Scene> {
        NSFetchRequest<Scene>(entityName: "Scene")
    }

    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var createdAt: Date
    @NSManaged var colorHex: String?
    @NSManaged private var equipments: NSSet?

    var equipmentSet: Set<Equipment> {
        get { equipments as? Set<Equipment> ?? [] }
        set { equipments = newValue as NSSet }
    }

    var equipmentsArray: [Equipment] {
        equipmentSet.sorted { $0.createdAt > $1.createdAt }
    }

    var equipmentCount: Int {
        equipmentSet.count
    }

    var totalInvestment: Double {
        equipmentSet.reduce(0) { $0 + $1.price }
    }

    var averageDailyCost: Double {
        guard !equipmentSet.isEmpty else { return 0 }
        let totalDailyCost = equipmentSet.reduce(0) { $0 + $1.dailyCost }
        return totalDailyCost / Double(equipmentSet.count)
    }
}
