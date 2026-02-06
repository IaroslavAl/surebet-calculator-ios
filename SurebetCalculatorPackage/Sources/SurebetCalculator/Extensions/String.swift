import Foundation

public extension String {
    /// Парсит строку в Double с учётом текущей локали.
    /// Нормализует десятичный разделитель для поддержки обоих вариантов ввода (точка и запятая).
    func formatToDouble() -> Double? {
        let normalized = normalizeDecimalSeparator()
        let formatter = NumberFormatterCache.decimal(locale: Locale.current)
        return formatter.number(from: normalized)?.doubleValue
    }

    /// Нормализует десятичный разделитель в строке.
    /// Заменяет точку на разделитель текущей локали, если локаль использует запятую.
    /// Это обеспечивает поддержку обоих вариантов ввода (точка и запятая) независимо от локали.
    private func normalizeDecimalSeparator() -> String {
        let decimalSeparator = Locale.current.decimalSeparator

        // Если текущая локаль использует запятую, заменяем точку на запятую
        // Это позволяет корректно обрабатывать ввод с точкой для локалей с запятой
        if decimalSeparator == "," {
            return self.replacingOccurrences(of: ".", with: ",")
        }
        // Если текущая локаль использует точку, оставляем как есть
        return self
    }

    func isValidDouble() -> Bool {
        let value = self.formatToDouble()
        return value != nil || self.isEmpty
    }

    /// Проверяет, является ли строка неотрицательным числом
    func isNumberNotNegative() -> Bool {
        if let value = self.formatToDouble() {
            return value >= 0
        }
        return true
    }
}
