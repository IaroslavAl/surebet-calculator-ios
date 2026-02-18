import Foundation
import Testing
@testable import SurebetCalculator

struct LocalizationTests {
    @Test
    func calculatorNavigationTitleWhenRussianLocale() {
        let value = SurebetCalculatorLocalizationKey.navigationTitle.localized(Locale(identifier: "ru"))
        #expect(value == "Калькулятор")
    }

    @Test
    func calculatorNavigationTitleWhenGermanLocale() {
        let value = SurebetCalculatorLocalizationKey.navigationTitle.localized(Locale(identifier: "de"))
        #expect(value == "Rechner")
    }

    @Test
    func calculatorNavigationTitleWhenGermanRegionLocale() {
        let value = SurebetCalculatorLocalizationKey.navigationTitle.localized(Locale(identifier: "de_DE"))
        #expect(value == "Rechner")
    }
}
