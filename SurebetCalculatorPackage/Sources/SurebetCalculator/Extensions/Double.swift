import Foundation

extension Double {
    func formatToString(isPercent: Bool = false) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        // swiftlint:disable:next legacy_objc_type
        let formattedValue = formatter.string(from: self as NSNumber) ?? "0.00"
        return isPercent ? formattedValue + "%" : formattedValue
    }
}
