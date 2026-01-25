import XCTest

/// UI тесты для калькулятора сурбетов.
/// Тестирует основные пользовательские сценарии.
@MainActor
final class SurebetCalculatorUITests: XCTestCase {
    // MARK: - Properties

    private var app: XCUIApplication!

    // MARK: - Lifecycle

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDown() async throws {
        app = nil
        try await super.tearDown()
    }

    // MARK: - Happy Path Tests

    /// Тест: Запуск приложения и показ онбординга для нового пользователя
    func testAppLaunchShowsOnboardingForNewUser() throws {
        app.launchArguments = ["-resetUserDefaults"]
        app.launch()

        let onboardingView = app.otherElements[Identifiers.Onboarding.view]
        XCTAssertTrue(
            onboardingView.waitForExistence(timeout: 5),
            "Онбординг должен отображаться для нового пользователя"
        )

        // Ищем кнопку по тексту "More details" (первая страница онбординга)
        let moreDetailsButton = app.buttons["More details"]
        XCTAssertTrue(
            moreDetailsButton.waitForExistence(timeout: 2),
            "Кнопка 'More details' должна отображаться"
        )
    }

    /// Тест: Прохождение онбординга полностью (3 страницы)
    func testOnboardingCompleteFlow() throws {
        app.launchArguments = ["-resetUserDefaults"]
        app.launch()

        let onboardingView = app.otherElements[Identifiers.Onboarding.view]
        guard onboardingView.waitForExistence(timeout: 5) else {
            XCTFail("Онбординг не отображается")
            return
        }

        // Страница 0: "More details"
        let moreDetailsButton = app.buttons["More details"]
        XCTAssertTrue(
            moreDetailsButton.waitForExistence(timeout: 2),
            "Кнопка 'More details' должна отображаться"
        )
        moreDetailsButton.tap()
        Thread.sleep(forTimeInterval: 0.3)

        // Страница 1: "Next"
        let nextButton = app.buttons["Next"]
        XCTAssertTrue(
            nextButton.waitForExistence(timeout: 2),
            "Кнопка 'Next' должна отображаться"
        )
        nextButton.tap()
        Thread.sleep(forTimeInterval: 0.3)

        // Страница 2: "Close" - на последней странице есть две кнопки:
        // X ("Close onboarding") и основная ("Close")
        // Ищем все кнопки с текстом "Close" и берём ту, которая не "Close onboarding"
        let closeButtons = app.buttons.matching(NSPredicate(format: "label == 'Close'"))
        XCTAssertTrue(
            closeButtons.count > 0,
            "Кнопка 'Close' должна отображаться"
        )
        closeButtons.firstMatch.tap()

        // После закрытия онбординга должен появиться калькулятор
        let navBar = app.navigationBars["Surebet calculator"]
        XCTAssertTrue(
            navBar.waitForExistence(timeout: 5),
            "Калькулятор должен отображаться после онбординга"
        )
    }

    /// Тест: Закрытие онбординга кнопкой X
    func testOnboardingCloseButton() throws {
        app.launchArguments = ["-resetUserDefaults"]
        app.launch()

        let onboardingView = app.otherElements[Identifiers.Onboarding.view]
        guard onboardingView.waitForExistence(timeout: 5) else {
            XCTFail("Онбординг не отображается")
            return
        }

        // Кнопка X имеет accessibilityLabel "Close onboarding"
        let closeButton = app.buttons["Close onboarding"]
        XCTAssertTrue(
            closeButton.waitForExistence(timeout: 2),
            "Кнопка закрытия онбординга должна отображаться"
        )
        closeButton.tap()

        let navBar = app.navigationBars["Surebet calculator"]
        XCTAssertTrue(
            navBar.waitForExistence(timeout: 5),
            "Калькулятор должен отображаться после закрытия онбординга"
        )
    }

    /// Тест: Ввод данных в калькулятор (через коэффициенты и общую сумму)
    /// По умолчанию selectedRow = .total, поэтому rowBetSize поля заблокированы.
    /// Работаем через totalBetSize и coefficient поля (они всегда enabled).
    func testCalculatorInputAndCalculation() throws {
        launchAppWithoutOnboarding()

        // Вводим общую сумму ставки
        let totalBetSize = app.textFields[Identifiers.TotalRow.betSizeTextField]
        XCTAssertTrue(totalBetSize.waitForExistence(timeout: 5))
        totalBetSize.tap()
        totalBetSize.typeText("1000")

        // Вводим коэффициенты (они всегда доступны)
        let row0Coefficient = app.textFields[Identifiers.Row.coefficientTextField(0)]
        row0Coefficient.tap()
        row0Coefficient.typeText("2")

        let row1Coefficient = app.textFields[Identifiers.Row.coefficientTextField(1)]
        row1Coefficient.tap()
        row1Coefficient.typeText("2")

        tapDoneButton()

        // Проверяем, что income отображается
        let incomeText = app.staticTexts[Identifiers.Row.incomeText(0)]
        XCTAssertTrue(
            incomeText.waitForExistence(timeout: 2),
            "Income должен отображаться после расчёта"
        )
    }

    /// Тест: Показ результата (profit percentage)
    func testProfitPercentageDisplay() throws {
        launchAppWithoutOnboarding()

        // Вводим коэффициенты для получения profit > 0
        let row0Coefficient = app.textFields[Identifiers.Row.coefficientTextField(0)]
        XCTAssertTrue(row0Coefficient.waitForExistence(timeout: 5))

        row0Coefficient.tap()
        row0Coefficient.typeText(formatNumberForInput(2.1))

        let row1Coefficient = app.textFields[Identifiers.Row.coefficientTextField(1)]
        row1Coefficient.tap()
        row1Coefficient.typeText(formatNumberForInput(2.1))

        // Вводим общую ставку
        let totalBetSize = app.textFields[Identifiers.TotalRow.betSizeTextField]
        totalBetSize.tap()
        totalBetSize.typeText("200")

        tapDoneButton()

        let profitPercentage = app.staticTexts[Identifiers.TotalRow.profitPercentageText]
        XCTAssertTrue(
            profitPercentage.waitForExistence(timeout: 2),
            "Profit percentage должен отображаться"
        )
    }

    // MARK: - Edge Cases Tests

    /// Тест: Очистка всех полей
    func testClearAllFields() throws {
        launchAppWithoutOnboarding()

        // Вводим данные через coefficient (всегда enabled)
        let row0Coefficient = app.textFields[Identifiers.Row.coefficientTextField(0)]
        XCTAssertTrue(row0Coefficient.waitForExistence(timeout: 5))

        row0Coefficient.tap()
        row0Coefficient.typeText(formatNumberForInput(2.5))

        let totalBetSize = app.textFields[Identifiers.TotalRow.betSizeTextField]
        totalBetSize.tap()
        totalBetSize.typeText("100")

        tapDoneButton()

        // Нажимаем кнопку очистки (trash icon в navigation bar)
        let clearButton = app.buttons[Identifiers.Calculator.clearButton]
        XCTAssertTrue(
            clearButton.waitForExistence(timeout: 2),
            "Кнопка очистки должна существовать"
        )
        clearButton.tap()

        Thread.sleep(forTimeInterval: 0.5)
        let betSizeValue = totalBetSize.value as? String ?? ""
        XCTAssertTrue(
            betSizeValue.isEmpty || betSizeValue == "Total bet size",
            "Поле должно быть очищено, получено: '\(betSizeValue)'"
        )
    }

    /// Тест: Добавление строки (кнопка +)
    func testAddRow() throws {
        launchAppWithoutOnboarding()

        let row0BetSize = app.textFields[Identifiers.Row.betSizeTextField(0)]
        let row1BetSize = app.textFields[Identifiers.Row.betSizeTextField(1)]
        var row2BetSize = app.textFields[Identifiers.Row.betSizeTextField(2)]

        XCTAssertTrue(row0BetSize.waitForExistence(timeout: 5))
        XCTAssertTrue(row1BetSize.exists)
        XCTAssertFalse(row2BetSize.exists, "Третья строка не должна существовать изначально")

        // Ищем кнопку + по accessibilityIdentifier (теперь это Button)
        let addButton = app.buttons[Identifiers.Calculator.addRowButton]
        XCTAssertTrue(
            addButton.waitForExistence(timeout: 2),
            "Кнопка добавления строки должна существовать"
        )
        addButton.tap()

        row2BetSize = app.textFields[Identifiers.Row.betSizeTextField(2)]
        XCTAssertTrue(
            row2BetSize.waitForExistence(timeout: 2),
            "Третья строка должна появиться после нажатия +"
        )
    }

    /// Тест: Удаление строки (кнопка -)
    func testRemoveRow() throws {
        launchAppWithoutOnboarding()

        // Сначала добавляем строку
        let addButton = app.buttons[Identifiers.Calculator.addRowButton]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
        addButton.tap()

        var row2BetSize = app.textFields[Identifiers.Row.betSizeTextField(2)]
        XCTAssertTrue(row2BetSize.waitForExistence(timeout: 2), "Третья строка должна появиться")

        // Удаляем строку
        let removeButton = app.buttons[Identifiers.Calculator.removeRowButton]
        XCTAssertTrue(removeButton.waitForExistence(timeout: 2))
        removeButton.tap()

        row2BetSize = app.textFields[Identifiers.Row.betSizeTextField(2)]
        XCTAssertFalse(
            row2BetSize.waitForExistence(timeout: 1),
            "Третья строка должна быть удалена"
        )
    }

    /// Тест: Невозможность удалить строки ниже минимума (2 строки)
    func testCannotRemoveBelowMinimumRows() throws {
        launchAppWithoutOnboarding()

        let removeButton = app.buttons[Identifiers.Calculator.removeRowButton]
        XCTAssertTrue(removeButton.waitForExistence(timeout: 2))
        removeButton.tap()

        let row0BetSize = app.textFields[Identifiers.Row.betSizeTextField(0)]
        let row1BetSize = app.textFields[Identifiers.Row.betSizeTextField(1)]

        XCTAssertTrue(row0BetSize.exists, "Первая строка должна существовать")
        XCTAssertTrue(row1BetSize.exists, "Вторая строка должна существовать")
    }

    /// Тест: Невозможность добавить строки выше максимума (10 строк)
    func testCannotAddAboveMaximumRows() throws {
        launchAppWithoutOnboarding()

        let addButton = app.buttons[Identifiers.Calculator.addRowButton]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))

        // Добавляем 8 строк (до 10)
        for _ in 0..<8 {
            addButton.tap()
            Thread.sleep(forTimeInterval: 0.1)
        }

        let row9BetSize = app.textFields[Identifiers.Row.betSizeTextField(9)]
        XCTAssertTrue(
            row9BetSize.waitForExistence(timeout: 2),
            "10-я строка должна существовать"
        )

        addButton.tap()

        let row10BetSize = app.textFields[Identifiers.Row.betSizeTextField(10)]
        XCTAssertFalse(
            row10BetSize.waitForExistence(timeout: 1),
            "11-я строка не должна существовать"
        )
    }

    /// Тест: Очистка текущего поля с клавиатуры
    func testKeyboardClearButton() throws {
        launchAppWithoutOnboarding()

        // Используем totalBetSize, который enabled по умолчанию
        let totalBetSize = app.textFields[Identifiers.TotalRow.betSizeTextField]
        XCTAssertTrue(totalBetSize.waitForExistence(timeout: 5))

        totalBetSize.tap()
        totalBetSize.typeText("12345")

        let clearButton = app.buttons[Identifiers.Keyboard.clearButton]
        if clearButton.waitForExistence(timeout: 2) {
            clearButton.tap()

            Thread.sleep(forTimeInterval: 0.3)
            let betSizeValue = totalBetSize.value as? String ?? ""
            XCTAssertTrue(
                betSizeValue.isEmpty || betSizeValue == "Total bet size",
                "Поле должно быть очищено"
            )
        }
    }

    /// Тест: Переключение между режимами расчёта (total/row)
    func testToggleCalculationMode() throws {
        launchAppWithoutOnboarding()

        // По умолчанию выбран total, проверяем что rowBetSize disabled
        let row0BetSize = app.textFields[Identifiers.Row.betSizeTextField(0)]
        XCTAssertTrue(row0BetSize.waitForExistence(timeout: 5))

        // Проверяем что поле заблокировано (isEnabled = false)
        XCTAssertFalse(
            row0BetSize.isEnabled,
            "rowBetSize должен быть disabled когда выбран total"
        )

        // Нажимаем на toggle button строки 0 чтобы выбрать её
        let row0Toggle = app.buttons[Identifiers.Row.toggleButton(0)]
        XCTAssertTrue(row0Toggle.waitForExistence(timeout: 2))
        row0Toggle.tap()

        Thread.sleep(forTimeInterval: 0.3)

        // Теперь rowBetSize должен быть enabled
        XCTAssertTrue(
            row0BetSize.isEnabled,
            "rowBetSize должен быть enabled когда выбрана эта строка"
        )
    }

    // MARK: - Private Helpers

    private func launchAppWithoutOnboarding() {
        app.launchArguments = ["-onboardingIsShown"]
        app.launch()

        let navBar = app.navigationBars["Surebet calculator"]
        XCTAssertTrue(
            navBar.waitForExistence(timeout: 5),
            "Калькулятор должен отображаться"
        )
    }

    private func tapDoneButton() {
        let doneButton = app.buttons[Identifiers.Keyboard.doneButton]
        if doneButton.waitForExistence(timeout: 1) {
            doneButton.tap()
        }
    }

    /// Форматирует число в строку для ввода в текстовое поле с учётом текущей локали.
    private func formatNumberForInput(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value as NSNumber) ?? ""
    }
}

// MARK: - Accessibility Identifiers

/// Идентификаторы доступности для UI тестов.
/// Должны соответствовать идентификаторам в коде приложения.
private enum Identifiers {
    enum Onboarding {
        static let view = "onboarding_view"
        static let closeButton = "onboarding_close_button"
        static let nextButton = "onboarding_next_button"
    }

    enum Calculator {
        static let view = "calculator_view"
        static let clearButton = "calculator_clear_button"
        static let addRowButton = "calculator_add_row_button"
        static let removeRowButton = "calculator_remove_row_button"
    }

    enum TotalRow {
        static let toggleButton = "total_row_toggle_button"
        static let betSizeTextField = "total_row_bet_size_text_field"
        static let profitPercentageText = "total_row_profit_percentage_text"
    }

    enum Row {
        static func toggleButton(_ id: Int) -> String {
            "row_\(id)_toggle_button"
        }

        static func betSizeTextField(_ id: Int) -> String {
            "row_\(id)_bet_size_text_field"
        }

        static func coefficientTextField(_ id: Int) -> String {
            "row_\(id)_coefficient_text_field"
        }

        static func incomeText(_ id: Int) -> String {
            "row_\(id)_income_text"
        }
    }

    enum Keyboard {
        static let clearButton = "keyboard_clear_button"
        static let doneButton = "keyboard_done_button"
    }
}
