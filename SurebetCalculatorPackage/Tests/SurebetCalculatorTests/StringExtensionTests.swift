@testable import SurebetCalculator
import Foundation
import Testing

struct StringExtensionTests {
    // MARK: - formatToDouble() Tests

    @Test
    func formatToDoubleWhenValidNumberWithDecimalSeparator() {
        // Given
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        let testValue = 123.45
        let string = formatter.string(from: testValue as NSNumber) ?? ""

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
        // Нормализация должна работать: если локаль использует запятую,
        // точка будет заменена на запятую, и парсинг пройдёт успешно
        // Это позволяет корректно обрабатывать ввод из .decimalPad
        #expect(result == 123.45)
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
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.groupingSeparator = " "
        let testValue = 1234.56
        let string = formatter.string(from: testValue as NSNumber) ?? ""

        // When
        let result = string.formatToDouble()

        // Then
        // NumberFormatter может обработать пробелы как разделители тысяч
        #expect(result != nil)
    }

    @Test
    func formatToDoubleWhenNegativeNumber() {
        // Given
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        let testValue = -123.45
        let string = formatter.string(from: testValue as NSNumber) ?? ""

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
    func formatToDoubleWhenCurrentLocale() {
        // Given
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        let testValue = 1234.56
        let string = formatter.string(from: testValue as NSNumber) ?? ""

        // When
        let result = string.formatToDouble()

        // Then
        #expect(result == 1234.56)
    }

    @Test
    func formatToDoubleWhenPointFromDecimalPadWithCommaLocale() {
        // Given
        // Симулируем ситуацию: локаль использует запятую, но .decimalPad ввёл точку
        // Это реальная проблема iOS: .decimalPad всегда показывает точку
        let stringWithPoint = "123.45"
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        let currentSeparator = formatter.decimalSeparator

        // When
        let result = stringWithPoint.formatToDouble()

        // Then
        // Нормализация должна работать: точка заменяется на разделитель текущей локали
        // Поэтому парсинг должен пройти успешно независимо от локали
        #expect(result == 123.45)
        
        // Дополнительная проверка: если локаль использует запятую,
        // то нормализация должна была заменить точку на запятую
        if currentSeparator == "," {
            // Проверяем, что нормализация работает
            let normalized = stringWithPoint.replacingOccurrences(of: ".", with: ",")
            let formatter2 = NumberFormatter()
            formatter2.numberStyle = .decimal
            formatter2.locale = Locale.current
            let parsed = formatter2.number(from: normalized)
            #expect(parsed?.doubleValue == 123.45)
        }
    }

    // MARK: - isValidDouble() Tests

    @Test
    func isValidDoubleWhenValidNumber() {
        // Given
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        let testValue = 123.45
        let string = formatter.string(from: testValue as NSNumber) ?? ""

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
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        let testValue = -123.45
        let string = formatter.string(from: testValue as NSNumber) ?? ""

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
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        let testValue = 123.45
        let string = formatter.string(from: testValue as NSNumber) ?? ""

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
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        let testValue = -123.45
        let string = formatter.string(from: testValue as NSNumber) ?? ""

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
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        let testValue = 999999.99
        let string = formatter.string(from: testValue as NSNumber) ?? ""

        // When
        let result = string.isNumberNotNegative()

        // Then
        #expect(result == true)
    }
}
