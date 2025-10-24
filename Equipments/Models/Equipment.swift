import CoreData
import Foundation

@objc(Equipment)
public class Equipment: NSManagedObject {
}

public extension Equipment {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Equipment> {
        NSFetchRequest<Equipment>(entityName: "Equipment")
    }

    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var price: Double
    @NSManaged var currencyCode: String?
    @NSManaged var purchaseDate: Date
    @NSManaged var createdAt: Date
    @NSManaged var updatedAt: Date
    @NSManaged var notes: String?
    @NSManaged var scene: Scene?

    var dailyCost: Double {
        let calendar = Calendar.current
        let startOfPurchase = calendar.startOfDay(for: purchaseDate)
        let startOfToday = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: startOfPurchase, to: startOfToday)
        let days = max(1, (components.day ?? 0) + 1)
        return price / Double(days)
    }

    var currencySymbol: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let currencyCode {
            formatter.currencyCode = currencyCode
        }
        return formatter.currencySymbol
    }

    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let currencyCode {
            formatter.currencyCode = currencyCode
        }
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }

    var formattedDailyCost: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let currencyCode {
            formatter.currencyCode = currencyCode
        }
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        let value = formatter.string(from: NSNumber(value: dailyCost)) ?? "\(dailyCost)"
        return value
    }
}
