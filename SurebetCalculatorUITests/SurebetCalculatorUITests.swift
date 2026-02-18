import XCTest

/// UI тесты для калькулятора сурбетов.
/// Тестируют ключевые пользовательские сценарии без привязки к локализованным строкам.
final class SurebetCalculatorUITests: XCTestCase {
    // MARK: - Properties

    private var app: XCUIApplication!

    // MARK: - Lifecycle

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = MainActor.assumeIsolated { XCUIApplication() }
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Happy Path Tests

    /// Тест: Запуск приложения и показ онбординга для нового пользователя.
    @MainActor
    func testAppLaunchShowsOnboardingForNewUser() throws {
        app.launchArguments = ["-resetUserDefaults", "-enableOnboarding"]
        app.launch()

        XCTAssertTrue(waitForOnboardingToAppear(timeout: 5), "Онбординг должен отображаться")

        let nextButton = onboardingNextButtonElement()
        XCTAssertTrue(nextButton.waitForExistence(timeout: 2), "Кнопка продолжения онбординга должна отображаться")
    }

    /// Тест: Прохождение онбординга полностью.
    @MainActor
    func testOnboardingCompleteFlow() throws {
        app.launchArguments = ["-resetUserDefaults", "-enableOnboarding"]
        app.launch()

        XCTAssertTrue(waitForOnboardingToAppear(timeout: 5), "Онбординг должен отображаться")

        tapOnboardingNextButton(times: 3)

        let calculatorAction = app.buttons[Identifiers.MainMenu.calculatorAction]
        XCTAssertTrue(
            calculatorAction.waitForExistence(timeout: 5),
            "Главное меню должно отображаться после завершения онбординга"
        )
    }

    /// Тест: Закрытие онбординга кнопкой закрытия.
    @MainActor
    func testOnboardingCloseButton() throws {
        app.launchArguments = ["-resetUserDefaults", "-enableOnboarding"]
        app.launch()

        XCTAssertTrue(waitForOnboardingToAppear(timeout: 5), "Онбординг должен отображаться")

        let closeButton = onboardingCloseButtonElement()
        XCTAssertTrue(closeButton.waitForExistence(timeout: 2), "Кнопка закрытия должна отображаться")
        closeButton.tap()

        XCTAssertTrue(
            app.buttons[Identifiers.MainMenu.calculatorAction].waitForExistence(timeout: 5),
            "Главное меню должно отображаться после закрытия онбординга"
        )
    }

    /// Тест: Открытие экрана настроек.
    @MainActor
    func testOpenSettingsFromMainMenu() throws {
        launchAppToMainMenuWithoutOnboarding()

        tapMainMenuAction(Identifiers.MainMenu.settingsAction)

        let settingsView = app.otherElements[Identifiers.Settings.view]
        XCTAssertTrue(settingsView.waitForExistence(timeout: 5), "Экран настроек должен отображаться")
    }

    /// Тест: Открытие экрана инструкции.
    @MainActor
    func testOpenInstructionsFromMainMenu() throws {
        launchAppToMainMenuWithoutOnboarding()

        tapMainMenuAction(Identifiers.MainMenu.instructionsAction)

        let instructionsView = app.otherElements[Identifiers.Instructions.view]
        XCTAssertTrue(instructionsView.waitForExistence(timeout: 5), "Экран инструкции должен отображаться")
    }

    /// Тест: Ввод данных в калькулятор (через коэффициенты и общую сумму).
    @MainActor
    func testCalculatorInputAndCalculation() throws {
        launchAppWithoutOnboarding()

        let totalBetSize = app.textFields[Identifiers.TotalRow.betSizeTextField]
        XCTAssertTrue(totalBetSize.waitForExistence(timeout: 5))
        totalBetSize.tap()
        totalBetSize.typeText("1000")

        let row0Coefficient = app.textFields[Identifiers.Row.coefficientTextField(0)]
        row0Coefficient.tap()
        row0Coefficient.typeText("2")

        let row1Coefficient = app.textFields[Identifiers.Row.coefficientTextField(1)]
        row1Coefficient.tap()
        row1Coefficient.typeText("2")

        tapDoneButton()

        let incomeText = app.staticTexts[Identifiers.Row.incomeText(0)]
        XCTAssertTrue(
            incomeText.waitForExistence(timeout: 2),
            "Доход должен отображаться после расчета"
        )
    }

    /// Тест: Показ результата (profit percentage).
    @MainActor
    func testProfitPercentageDisplay() throws {
        launchAppWithoutOnboarding()

        let row0Coefficient = app.textFields[Identifiers.Row.coefficientTextField(0)]
        XCTAssertTrue(row0Coefficient.waitForExistence(timeout: 5))

        row0Coefficient.tap()
        row0Coefficient.typeText(formatNumberForInput(2.1))

        let row1Coefficient = app.textFields[Identifiers.Row.coefficientTextField(1)]
        row1Coefficient.tap()
        row1Coefficient.typeText(formatNumberForInput(2.1))

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

    /// Тест: Очистка всех полей.
    @MainActor
    func testClearAllFields() throws {
        launchAppWithoutOnboarding()

        let row0Coefficient = app.textFields[Identifiers.Row.coefficientTextField(0)]
        XCTAssertTrue(row0Coefficient.waitForExistence(timeout: 5))

        row0Coefficient.tap()
        row0Coefficient.typeText(formatNumberForInput(2.5))

        let totalBetSize = app.textFields[Identifiers.TotalRow.betSizeTextField]
        totalBetSize.tap()
        totalBetSize.typeText("100")
        tapDoneButton()

        let previousValue = stringValue(of: totalBetSize)
        let clearButton = app.buttons[Identifiers.Calculator.clearButton]
        XCTAssertTrue(clearButton.waitForExistence(timeout: 2), "Кнопка очистки должна существовать")
        clearButton.tap()

        XCTAssertTrue(
            waitForTextFieldValueChange(totalBetSize, from: previousValue, timeout: 2),
            "Значение total bet size должно измениться после очистки"
        )

        let currentValue = stringValue(of: totalBetSize)
        XCTAssertFalse(currentValue.contains("100"), "Поле total bet size должно быть очищено")
    }

    /// Тест: Изменение количества строк через контрол количества исходов.
    @MainActor
    func testChangeRowCount() throws {
        launchAppWithoutOnboarding()

        let row0BetSize = app.textFields[Identifiers.Row.betSizeTextField(0)]
        let row1BetSize = app.textFields[Identifiers.Row.betSizeTextField(1)]
        var row2BetSize = app.textFields[Identifiers.Row.betSizeTextField(2)]

        XCTAssertTrue(row0BetSize.waitForExistence(timeout: 5))
        XCTAssertTrue(row1BetSize.exists)
        XCTAssertFalse(row2BetSize.exists, "Третья строка не должна существовать изначально")

        selectRowCount(3)

        row2BetSize = app.textFields[Identifiers.Row.betSizeTextField(2)]
        XCTAssertTrue(row2BetSize.waitForExistence(timeout: 2), "Третья строка должна появиться")
    }

    /// Тест: Уменьшение количества строк через контрол количества исходов.
    @MainActor
    func testReduceRowCount() throws {
        launchAppWithoutOnboarding()

        selectRowCount(3)

        var row2BetSize = app.textFields[Identifiers.Row.betSizeTextField(2)]
        XCTAssertTrue(row2BetSize.waitForExistence(timeout: 2), "Третья строка должна появиться")

        selectRowCount(2)

        row2BetSize = app.textFields[Identifiers.Row.betSizeTextField(2)]
        XCTAssertFalse(row2BetSize.waitForExistence(timeout: 1), "Третья строка должна быть удалена")
    }

    /// Тест: Минимальное количество строк (2).
    @MainActor
    func testMinimumRowCount() throws {
        launchAppWithoutOnboarding()

        selectRowCount(2)

        XCTAssertTrue(app.textFields[Identifiers.Row.betSizeTextField(0)].exists)
        XCTAssertTrue(app.textFields[Identifiers.Row.betSizeTextField(1)].exists)
        XCTAssertFalse(app.textFields[Identifiers.Row.betSizeTextField(2)].exists)
    }

    /// Тест: Максимальное количество строк (20).
    @MainActor
    func testMaximumRowCount() throws {
        launchAppWithoutOnboarding()

        selectRowCount(20)

        let row19BetSize = app.textFields[Identifiers.Row.betSizeTextField(19)]
        XCTAssertTrue(row19BetSize.waitForExistence(timeout: 2), "20-я строка должна существовать")

        let row20BetSize = app.textFields[Identifiers.Row.betSizeTextField(20)]
        XCTAssertFalse(row20BetSize.waitForExistence(timeout: 1), "21-я строка не должна существовать")
    }

    /// Тест: Очистка текущего поля с клавиатуры.
    @MainActor
    func testKeyboardClearButton() throws {
        launchAppWithoutOnboarding()

        let totalBetSize = app.textFields[Identifiers.TotalRow.betSizeTextField]
        XCTAssertTrue(totalBetSize.waitForExistence(timeout: 5))

        totalBetSize.tap()
        totalBetSize.typeText("12345")

        let clearButton = app.buttons[Identifiers.Keyboard.clearButton]
        guard clearButton.waitForExistence(timeout: 2) else {
            XCTFail("Кнопка очистки клавиатуры должна существовать")
            return
        }

        let previousValue = stringValue(of: totalBetSize)
        clearButton.tap()

        XCTAssertTrue(
            waitForTextFieldValueChange(totalBetSize, from: previousValue, timeout: 2),
            "Значение поля должно измениться после нажатия clear"
        )

        let currentValue = stringValue(of: totalBetSize)
        XCTAssertFalse(currentValue.contains("12345"), "Поле должно быть очищено")
    }

    /// Тест: Переключение между режимами расчета (total/row).
    @MainActor
    func testToggleCalculationMode() throws {
        launchAppWithoutOnboarding()

        let row0BetSize = app.textFields[Identifiers.Row.betSizeTextField(0)]
        XCTAssertTrue(row0BetSize.waitForExistence(timeout: 5))
        XCTAssertFalse(row0BetSize.isEnabled, "rowBetSize должен быть disabled при selected total")

        let row0Toggle = app.buttons[Identifiers.Row.toggleButton(0)]
        XCTAssertTrue(row0Toggle.waitForExistence(timeout: 2), "Тоггл строки должен существовать")
        row0Toggle.tap()

        XCTAssertTrue(
            waitForElementToBecomeEnabled(row0BetSize, timeout: 2),
            "rowBetSize должен стать enabled после выбора строки"
        )
    }

    // MARK: - Private Helpers

    @MainActor
    private func launchAppWithoutOnboarding() {
        launchAppToMainMenuWithoutOnboarding()
        openCalculatorFromMainMenu()
    }

    @MainActor
    private func launchAppToMainMenuWithoutOnboarding() {
        app.launchArguments = ["-disableOnboarding", "-onboardingIsShown"]
        app.launch()
        waitForOnboardingToDisappearIfNeeded()
        assertMainMenuIsVisible()
    }

    @MainActor
    private func tapOnboardingNextButton(times: Int) {
        for _ in 0..<times {
            let nextButton = onboardingNextButtonElement()
            XCTAssertTrue(nextButton.waitForExistence(timeout: 2), "Кнопка онбординга должна существовать")
            nextButton.tap()
        }
    }

    @MainActor
    private func assertMainMenuIsVisible() {
        XCTAssertTrue(
            app.buttons[Identifiers.MainMenu.calculatorAction].waitForExistence(timeout: 5),
            "Главное меню должно отображаться"
        )
    }

    @MainActor
    private func openCalculatorFromMainMenu() {
        let calculatorActions = app.buttons.matching(identifier: Identifiers.MainMenu.calculatorAction)
        let calculatorAction = calculatorActions.firstMatch
        XCTAssertTrue(calculatorAction.waitForExistence(timeout: 5), "Переход в калькулятор должен быть доступен")

        var didTap = false
        let candidateCount = min(calculatorActions.count, 3)
        if candidateCount > 1 {
            for index in 0..<candidateCount {
                let candidate = calculatorActions.element(boundBy: index)
                if candidate.exists, candidate.isHittable {
                    candidate.tap()
                    didTap = true
                    break
                }
            }
        }

        if !didTap {
            calculatorAction.tap()
        }

        if !isCalculatorVisible(timeout: 2) {
            // Fallback для случая, когда XCUITest выбрал неактивный дубликат.
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3)).tap()
        }

        assertCalculatorIsVisible()
    }

    @MainActor
    private func tapMainMenuAction(_ identifier: String) {
        let actions = app.buttons.matching(identifier: identifier)
        let primary = actions.firstMatch
        XCTAssertTrue(primary.waitForExistence(timeout: 5), "Кнопка главного меню должна существовать")

        let candidateCount = min(actions.count, 3)
        if candidateCount > 1 {
            for index in 0..<candidateCount {
                let candidate = actions.element(boundBy: index)
                if candidate.exists, candidate.isHittable {
                    candidate.tap()
                    return
                }
            }
        }
        primary.tap()
    }

    @MainActor
    private func assertCalculatorIsVisible() {
        XCTAssertTrue(isCalculatorVisible(timeout: 5), "Калькулятор должен отображаться")
    }

    @MainActor
    private func isCalculatorVisible(timeout: TimeInterval) -> Bool {
        let row0Coefficient = app.textFields[Identifiers.Row.coefficientTextField(0)]
        return row0Coefficient.waitForExistence(timeout: timeout)
    }

    @MainActor
    private func waitForOnboardingToDisappearIfNeeded() {
        let closeButton = onboardingCloseButtonElement()
        let nextButton = onboardingNextButtonElement()

        guard closeButton.exists || nextButton.exists else { return }

        let closeExpectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: closeButton
        )
        let nextExpectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: nextButton
        )
        _ = XCTWaiter().wait(for: [closeExpectation, nextExpectation], timeout: 5)
    }

    @MainActor
    private func waitForOnboardingToAppear(timeout: TimeInterval) -> Bool {
        let closeButton = onboardingCloseButtonElement()
        let nextButton = onboardingNextButtonElement()
        return closeButton.waitForExistence(timeout: timeout)
            && nextButton.waitForExistence(timeout: timeout)
    }

    @MainActor
    private func onboardingCloseButtonElement() -> XCUIElement {
        app.descendants(matching: .any)[Identifiers.Onboarding.closeButton]
    }

    @MainActor
    private func onboardingNextButtonElement() -> XCUIElement {
        app.descendants(matching: .any)[Identifiers.Onboarding.nextButton]
    }

    @MainActor
    private func tapDoneButton() {
        let doneButton = app.buttons[Identifiers.Keyboard.doneButton]
        if doneButton.waitForExistence(timeout: 1) {
            doneButton.tap()
        }
    }

    @MainActor
    private func selectRowCount(_ value: Int) {
        let decreaseControl = app.descendants(matching: .any)[Identifiers.Calculator.rowCountDecreaseButton]
        let increaseControl = app.descendants(matching: .any)[Identifiers.Calculator.rowCountIncreaseButton]
        let valueLabel = app.descendants(matching: .any)[Identifiers.Calculator.rowCountValue]

        XCTAssertTrue(decreaseControl.waitForExistence(timeout: 2), "Кнопка уменьшения должна существовать")
        XCTAssertTrue(increaseControl.waitForExistence(timeout: 2), "Кнопка увеличения должна существовать")
        XCTAssertTrue(valueLabel.waitForExistence(timeout: 2), "Текущее значение должно существовать")

        var current = Int(valueLabel.label) ?? 0
        var guardCounter = 0
        while current < value && guardCounter < 30 {
            increaseControl.tap()
            current = Int(valueLabel.label) ?? current
            guardCounter += 1
        }
        while current > value && guardCounter < 60 {
            decreaseControl.tap()
            current = Int(valueLabel.label) ?? current
            guardCounter += 1
        }

        XCTAssertEqual(current, value, "Количество исходов должно быть \(value)")
    }

    @MainActor
    private func waitForTextFieldValueChange(
        _ textField: XCUIElement,
        from oldValue: String,
        timeout: TimeInterval
    ) -> Bool {
        let predicate = NSPredicate(format: "value != %@", oldValue)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: textField)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    @MainActor
    private func waitForElementToBecomeEnabled(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "isEnabled == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    @MainActor
    private func stringValue(of textField: XCUIElement) -> String {
        textField.value as? String ?? ""
    }

    /// Форматирует число в строку для ввода в текстовое поле с учетом текущей локали.
    private func formatNumberForInput(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value as NSNumber) ?? ""
    }
}

// MARK: - Accessibility Identifiers

private enum Identifiers {
    enum MainMenu {
        static let calculatorAction = "main_menu_calculator_action"
        static let settingsAction = "main_menu_settings_action"
        static let instructionsAction = "main_menu_instructions_action"
    }

    enum Onboarding {
        static let closeButton = "onboarding_close_button"
        static let nextButton = "onboarding_next_button"
    }

    enum Settings {
        static let view = "settings_view"
    }

    enum Instructions {
        static let view = "menu_instructions_view"
    }

    enum Calculator {
        static let clearButton = "calculator_clear_button"
        static let rowCountDecreaseButton = "calculator_row_count_decrease_button"
        static let rowCountIncreaseButton = "calculator_row_count_increase_button"
        static let rowCountValue = "calculator_row_count_value"
    }

    enum TotalRow {
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
