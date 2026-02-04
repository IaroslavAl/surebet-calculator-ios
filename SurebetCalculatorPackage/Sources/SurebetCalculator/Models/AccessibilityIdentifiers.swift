/// Идентификаторы доступности для UI элементов калькулятора.
/// Используются для UI тестов.
public enum AccessibilityIdentifiers: Sendable {
    // MARK: - Calculator

    /// Идентификаторы для основного экрана калькулятора
    public enum Calculator: Sendable {
        public static let view = "calculator_view"
        public static let clearButton = "calculator_clear_button"
        public static let rowCountPicker = "calculator_row_count_picker"
    }

    // MARK: - Total Row

    /// Идентификаторы для строки с итоговой суммой
    public enum TotalRow: Sendable {
        public static let toggleButton = "total_row_toggle_button"
        public static let betSizeTextField = "total_row_bet_size_text_field"
        public static let profitPercentageText = "total_row_profit_percentage_text"
    }

    // MARK: - Row

    /// Идентификаторы для строк с коэффициентами
    public enum Row: Sendable {
        public static func toggleButton(_ id: Int) -> String {
            "row_\(id)_toggle_button"
        }

        public static func betSizeTextField(_ id: Int) -> String {
            "row_\(id)_bet_size_text_field"
        }

        public static func coefficientTextField(_ id: Int) -> String {
            "row_\(id)_coefficient_text_field"
        }

        public static func incomeText(_ id: Int) -> String {
            "row_\(id)_income_text"
        }
    }

    // MARK: - Keyboard

    /// Идентификаторы для кнопок клавиатуры
    public enum Keyboard: Sendable {
        public static let clearButton = "keyboard_clear_button"
        public static let doneButton = "keyboard_done_button"
    }
}
