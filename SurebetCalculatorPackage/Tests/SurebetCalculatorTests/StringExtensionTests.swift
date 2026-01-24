@testable import SurebetCalculator
import Testing

struct StringExtensionTests {
    // MARK: - formatToDouble() Tests

    @Test
    func formatToDoubleWhenValidNumberWithComma() {
        // Given
        let string = "123,45"

        // When
        let result = string.formatToDouble()

        // Then
        #expect(result == 123.45)
    }

    @Test
    func formatToDoubleWhenValidNumberWithPoint() {
        // Given
        let string = "123.45"

        // When
        let result = string.formatToDouble()

        // Then
        // NumberFormatter с ru_RU локализацией использует запятую как разделитель
        // Точка не распарсится корректно, результат будет nil
        #expect(result == nil)
    }

    @Test
    func formatToDoubleWhenInvalidString() {
        // Given
        let string = "abc"

        // When
        let result = string.formatToDouble()

        // Then
        #expect(result == nil)
    }

    @Test
    func formatToDoubleWhenEmptyString() {
        // Given
        let string = ""

        // When
        let result = string.formatToDouble()

        // Then
        #expect(result == nil)
    }

    @Test
    func formatToDoubleWhenNumberWithSpaces() {
        // Given
        let string = "1 234,56"

        // When
        let result = string.formatToDouble()

        // Then
        // NumberFormatter может обработать пробелы как разделители тысяч
        #expect(result != nil)
    }

    @Test
    func formatToDoubleWhenNegativeNumber() {
        // Given
        let string = "-123,45"

        // When
        let result = string.formatToDouble()

        // Then
        #expect(result == -123.45)
    }

    @Test
    func formatToDoubleWhenZero() {
        // Given
        let string = "0"

        // When
        let result = string.formatToDouble()

        // Then
        #expect(result == 0.0)
    }

    @Test
    func formatToDoubleWhenLocalizationRuRu() {
        // Given
        let string = "1234,56"

        // When
        let result = string.formatToDouble()

        // Then
        #expect(result == 1234.56)
    }

    // MARK: - isValidDouble() Tests

    @Test
    func isValidDoubleWhenValidNumber() {
        // Given
        let string = "123,45"

        // When
        let result = string.isValidDouble()

        // Then
        #expect(result == true)
    }

    @Test
    func isValidDoubleWhenInvalidString() {
        // Given
        let string = "abc"

        // When
        let result = string.isValidDouble()

        // Then
        // formatToDouble() вернет nil, isEmpty = false, formatToDouble() ?? 0 > 0 = false
        // Результат: false || false || false = false
        #expect(result == false)
    }

    @Test
    func isValidDoubleWhenEmptyString() {
        // Given
        let string = ""

        // When
        let result = string.isValidDouble()

        // Then
        #expect(result == true) // Пустая строка возвращает true
    }

    @Test
    func isValidDoubleWhenNegativeNumber() {
        // Given
        let string = "-123,45"

        // When
        let result = string.isValidDouble()

        // Then
        // formatToDouble() вернет -123.45, что не > 0, но может быть валидным
        #expect(result == true)
    }

    @Test
    func isValidDoubleWhenZero() {
        // Given
        let string = "0"

        // When
        let result = string.isValidDouble()

        // Then
        // formatToDouble() вернет 0, что не > 0, но может быть валидным
        #expect(result == true)
    }

    // MARK: - isNumberNotNegative() Tests

    @Test
    func isNumberNotNegativeWhenPositiveNumber() {
        // Given
        let string = "123,45"

        // When
        let result = string.isNumberNotNegative()

        // Then
        #expect(result == true)
    }

    @Test
    func isNumberNotNegativeWhenZero() {
        // Given
        let string = "0"

        // When
        let result = string.isNumberNotNegative()

        // Then
        #expect(result == true)
    }

    @Test
    func isNumberNotNegativeWhenNegativeNumber() {
        // Given
        let string = "-123,45"

        // When
        let result = string.isNumberNotNegative()

        // Then
        #expect(result == false)
    }

    @Test
    func isNumberNotNegativeWhenInvalidString() {
        // Given
        let string = "abc"

        // When
        let result = string.isNumberNotNegative()

        // Then
        // Невалидная строка возвращает true
        #expect(result == true)
    }

    @Test
    func isNumberNotNegativeWhenEmptyString() {
        // Given
        let string = ""

        // When
        let result = string.isNumberNotNegative()

        // Then
        // Пустая строка возвращает true
        #expect(result == true)
    }

    @Test
    func isNumberNotNegativeWhenLargePositiveNumber() {
        // Given
        let string = "999999,99"

        // When
        let result = string.isNumberNotNegative()

        // Then
        #expect(result == true)
    }
}
