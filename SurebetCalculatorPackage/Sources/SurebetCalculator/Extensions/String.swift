import Foundation

public extension String {
    /// Парсит строку в Double с учётом текущей локали.
    /// Нормализует десятичный разделитель: если локаль использует запятую,
    /// а пользователь ввёл точку (из .decimalPad), заменяет точку на запятую.
    func formatToDouble() -> Double? {
        let normalized = normalizeDecimalSeparator()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        if let formattedValue = formatter.number(from: normalized) {
            return formattedValue.doubleValue
        }
        return nil
    }
    
    /// Нормализует десятичный разделитель в строке.
    /// Заменяет точку на разделитель текущей локали, если локаль использует запятую.
    /// Это нужно, потому что .decimalPad всегда показывает точку, независимо от локали.
    private func normalizeDecimalSeparator() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        let decimalSeparator = formatter.decimalSeparator
        
        // Если текущая локаль использует запятую, заменяем точку на запятую
        // Это позволяет корректно обрабатывать ввод из .decimalPad
        if decimalSeparator == "," {
            return self.replacingOccurrences(of: ".", with: ",")
        }
        // Если текущая локаль использует точку, оставляем как есть
        return self
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
