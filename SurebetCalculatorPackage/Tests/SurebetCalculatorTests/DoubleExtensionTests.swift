@testable import SurebetCalculator
import Foundation
import Testing

struct DoubleExtensionTests {
    // MARK: - formatToString() Tests

    @Test
    func formatToStringWhenPositiveNumber() {
        // Given
        let value: Double = 123.45
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        let expected = formatter.string(from: value as NSNumber) ?? ""

        // When
        let result = value.formatToString()

        // Then
        #expect(result == expected)
    }

    @Test
    func formatToStringWhenNegativeNumber() {
        // Given
        let value: Double = -123.45
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        let expected = formatter.string(from: value as NSNumber) ?? ""

        // When
        let result = value.formatToString()

        // Then
        #expect(result == expected)
    }

    @Test
    func formatToStringWhenZero() {
        // Given
        let value: Double = 0.0

        // When
        let result = value.formatToString()

        // Then
        #expect(result == "0")
    }

    @Test
    func formatToStringWhenLargeNumber() {
        // Given
        let value: Double = 1_000_000.99
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        let expected = formatter.string(from: value as NSNumber) ?? ""

        // When
        let result = value.formatToString()

        // Then
        #expect(result == expected)
    }

    @Test
    func formatToStringWhenSmallNumber() {
        // Given
        let value: Double = 0.01
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        let expected = formatter.string(from: value as NSNumber) ?? ""

        // When
        let result = value.formatToString()

        // Then
        #expect(result == expected)
    }

    @Test
    func formatToStringWhenNumberWithFractionalPart() {
        // Given
        let value: Double = 42.567
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        let expected = formatter.string(from: value as NSNumber) ?? ""

        // When
        let result = value.formatToString()

        // Then
        // Округляется до 2 знаков после запятой
        #expect(result == expected)
    }

    @Test
    func formatToStringWhenNumberWithoutFractionalPart() {
        // Given
        let value: Double = 100.0

        // When
        let result = value.formatToString()

        // Then
        #expect(result == "100")
    }

    @Test
    func formatToStringWhenPercentFormat() {
        // Given
        let value: Double = 25.5
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        let expected = (formatter.string(from: value as NSNumber) ?? "") + "%"

        // When
        let result = value.formatToString(isPercent: true)

        // Then
        #expect(result == expected)
    }

    @Test
    func formatToStringWhenPercentFormatWithZero() {
        // Given
        let value: Double = 0.0

        // When
        let result = value.formatToString(isPercent: true)

        // Then
        #expect(result == "0%")
    }

    @Test
    func formatToStringWhenPercentFormatWithNegative() {
        // Given
        let value: Double = -10.25
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        let expected = (formatter.string(from: value as NSNumber) ?? "") + "%"

        // When
        let result = value.formatToString(isPercent: true)

        // Then
        #expect(result == expected)
    }

    @Test
    func formatToStringWhenCurrentLocale() {
        // Given
        let value: Double = 1234.56
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        let expected = formatter.string(from: value as NSNumber) ?? ""

        // When
        let result = value.formatToString()

        // Then
        // Проверяем, что используется правильный разделитель для текущей локали
        #expect(result == expected)
    }

    @Test
    func formatToStringWhenVerySmallNumber() {
        // Given
        let value: Double = 0.001

        // When
        let result = value.formatToString()

        // Then
        // Округляется до 2 знаков, должно быть 0
        #expect(result == "0")
    }

    @Test
    func formatToStringWhenVeryLargeNumber() {
        // Given
        let value: Double = 999_999_999.99
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        let expected = formatter.string(from: value as NSNumber) ?? ""

        // When
        let result = value.formatToString()

        // Then
        #expect(result == expected)
    }
}
