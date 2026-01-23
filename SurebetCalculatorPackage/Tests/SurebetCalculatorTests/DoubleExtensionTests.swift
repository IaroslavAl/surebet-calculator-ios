@testable import SurebetCalculator
import Testing

struct DoubleExtensionTests {
    // MARK: - formatToString() Tests

    @Test
    func formatToStringWhenPositiveNumber() {
        // Given
        let value: Double = 123.45

        // When
        let result = value.formatToString()

        // Then
        #expect(result == "123,45")
    }

    @Test
    func formatToStringWhenNegativeNumber() {
        // Given
        let value: Double = -123.45

        // When
        let result = value.formatToString()

        // Then
        #expect(result == "-123,45")
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

        // When
        let result = value.formatToString()

        // Then
        #expect(result == "1000000,99")
    }

    @Test
    func formatToStringWhenSmallNumber() {
        // Given
        let value: Double = 0.01

        // When
        let result = value.formatToString()

        // Then
        #expect(result == "0,01")
    }

    @Test
    func formatToStringWhenNumberWithFractionalPart() {
        // Given
        let value: Double = 42.567

        // When
        let result = value.formatToString()

        // Then
        // Округляется до 2 знаков после запятой
        #expect(result == "42,57")
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

        // When
        let result = value.formatToString(isPercent: true)

        // Then
        #expect(result == "25,5%")
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

        // When
        let result = value.formatToString(isPercent: true)

        // Then
        #expect(result == "-10,25%")
    }

    @Test
    func formatToStringWhenLocalizationRuRu() {
        // Given
        let value: Double = 1234.56

        // When
        let result = value.formatToString()

        // Then
        // Проверяем, что используется запятая как разделитель (ru_RU локализация)
        #expect(result.contains(","))
        #expect(!result.contains("."))
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

        // When
        let result = value.formatToString()

        // Then
        #expect(result == "999999999,99")
    }
}
