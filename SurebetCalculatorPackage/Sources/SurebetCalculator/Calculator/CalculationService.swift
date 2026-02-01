import Foundation

/// Протокол для сервиса вычислений в калькуляторе сурбетов.
/// Обеспечивает инверсию зависимостей и позволяет легко тестировать ViewModel.
protocol CalculationService: Sendable {
    /// Выполняет вычисления на основе текущего состояния калькулятора.
    /// - Parameter input: Текущее состояние калькулятора.
    /// - Returns: Результат расчёта (обновление, сброс производных, no-op или ошибка ввода).
    func calculate(input: CalculationInput) -> CalculationResult
}
