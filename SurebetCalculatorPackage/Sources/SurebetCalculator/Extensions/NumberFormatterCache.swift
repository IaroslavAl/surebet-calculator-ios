import Foundation

/// Кэш форматтеров по тредам, чтобы не создавать их на каждом вводе.
enum NumberFormatterCache {
    private static let decimalPrefix = "ru.surebet-calculator.formatter.decimal."
    private static let plainPrefix = "ru.surebet-calculator.formatter.plain."

    static func decimal(locale: Locale) -> NumberFormatter {
        cachedFormatter(prefix: decimalPrefix, locale: locale) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.locale = locale
            return formatter
        }
    }

    static func plain(locale: Locale) -> NumberFormatter {
        cachedFormatter(prefix: plainPrefix, locale: locale) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            formatter.locale = locale
            return formatter
        }
    }

    private static func cachedFormatter(
        prefix: String,
        locale: Locale,
        build: () -> NumberFormatter
    ) -> NumberFormatter {
        let key = NSString(string: prefix + locale.identifier)
        if let cached = Thread.current.threadDictionary[key] as? NumberFormatter {
            return cached
        }
        let formatter = build()
        Thread.current.threadDictionary[key] = formatter
        return formatter
    }
}
