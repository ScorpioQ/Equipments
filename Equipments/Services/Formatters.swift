import Foundation

enum Formatters {
    static func currencyString(value: Double, currencyCode: String? = nil) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        if let currencyCode {
            formatter.currencyCode = currencyCode
        } else if let localeCurrency = Locale.current.currency?.identifier {
            formatter.currencyCode = localeCurrency
        }
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    static func localizedDays(_ days: Int) -> String {
        let format = NSLocalizedString("common.days", comment: "")
        return String(format: format, days)
    }
}
