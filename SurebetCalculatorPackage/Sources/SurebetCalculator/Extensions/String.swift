import Foundation

public extension String {
    func formatToDouble() -> Double? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ru_RU")
        if let formattedValue = formatter.number(from: self) {
            return formattedValue.doubleValue
        }
        return nil
    }

    func isValidDouble() -> Bool {
        self.formatToDouble() != nil
        || self.isEmpty
        || self.formatToDouble() ?? 0 > 0
    }

    /// Проверяет, является ли строка неотрицательным числом
    func isNumberNotNegative() -> Bool {
        if let value = self.formatToDouble() {
            return value >= 0
        }
        return true
    }
}
