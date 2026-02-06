import Foundation

extension Double {
    func formatToString(isPercent: Bool = false) -> String {
        let formatter = NumberFormatterCache.plain(locale: Locale.current)
        // swiftlint:disable:next legacy_objc_type
        let formattedValue = formatter.string(from: self as NSNumber) ?? "0.00"
        return isPercent ? formattedValue + "%" : formattedValue
    }
}
