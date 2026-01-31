import Foundation

/// Структура для управления вычислениями в калькуляторе сурбетов.
/// Использует различные методы вычислений в зависимости от того, какое поле было изменено пользователем.
struct Calculator: Sendable {
    // MARK: - Properties

    /// Итоговая строка с общим размером ставки и процентом прибыли.
    let total: TotalRow
    /// Массив строк с данными о ставках (коэффициенты, размеры ставок, доходы).
    let rows: [Row]
    /// Выбранная строка для вычислений (nil, если выбрана итоговая строка или ничего не выбрано).
    let selectedRow: RowType?
    /// Диапазон индексов строк, которые отображаются и участвуют в вычислениях.
    let displayedRowIndexes: Range<Int>

    // MARK: - Public Methods

    /// Выполняет вычисления на основе выбранного метода и обновляет итоговые данные и строки.
    /// Метод вычислений определяется автоматически на основе того, какое поле было изменено:
    /// - Если изменена итоговая ставка - пересчитываются все строки пропорционально.
    /// - Если изменена ставка в конкретной строке - пересчитываются итоговая ставка и остальные строки.
    /// - Если изменены ставки в нескольких строках - пересчитывается итоговая ставка.
    /// - Returns: Кортеж с обновленными итоговыми данными и строками.
    func calculate() -> (total: TotalRow?, rows: [Row]?) {
        switch calculationMethod {
        case .total:
            return calculateTotal()
        case .rows:
            return calculateRows()
        case let .row(id):
            return calculateSpecificRow(id)
        case .none:
            return resetDerivedValues()
        }
    }
}

// MARK: - Private Methods

private extension Calculator {
    /// Вычисляет значение сурбета как обратную величину суммы обратных величин коэффициентов.
    /// Используется для определения, является ли комбинация ставок выигрышной (значение < 1.0).
    /// Формула: 1 / (1/k1 + 1/k2 + ... + 1/kn), где k1, k2, ..., kn - коэффициенты отображаемых строк.
    var surebetValue: Double {
        rows[displayedRowIndexes]
            .compactMap { $0.coefficient.formatToDouble() }
            .reduce(0) { $0 + (1 / $1) }
    }

    /// Проверяет, что все отображаемые строки имеют валидные и непустые размеры ставок.
    /// Используется для определения возможности вычисления итоговой ставки из суммы ставок по строкам.
    var hasValidBetSizes: Bool {
        rows[displayedRowIndexes]
            .map(\.betSize)
            .allSatisfy { $0.isValidDouble() && !$0.isEmpty }
    }

    /// Проверяет, что все отображаемые коэффициенты могут быть преобразованы в числа и являются положительными.
    /// Необходимо для корректного вычисления сурбета,
    /// так как отрицательные или нулевые коэффициенты делают вычисления невозможными.
    var hasValidCoefficients: Bool {
        rows[displayedRowIndexes]
            .map(\.coefficient)
            .allSatisfy { $0.formatToDouble() ?? 0 > 0 }
    }

    /// Определяет метод вычислений на основе валидности текущего ввода.
    /// Выбор метода зависит от того, какое поле было изменено пользователем:
    /// - Если изменена итоговая ставка - используется метод .total.
    /// - Если изменена ставка в конкретной строке - используется метод .row(id).
    /// - Если изменены ставки в нескольких строках - используется метод .rows.
    /// - Если данные невалидны - возвращается nil, вычисления не выполняются.
    var calculationMethod: CalculationMethod? {
        guard hasValidCoefficients else {
            return .none
        }
        switch selectedRow {
        case .total where total.betSize.isValidDouble() && !total.betSize.isEmpty:
            return .total
        case let .row(id) where rows[id].betSize.isValidDouble() && !rows[id].betSize.isEmpty:
            return .row(id)
        case .none where hasValidBetSizes:
            return .rows
        default:
            return .none
        }
    }

    /// Вычисляет итоговые данные для всех строк на основе текущих размеров ставок.
    /// Используется, когда пользователь изменил итоговую ставку - все строки пересчитываются пропорционально,
    /// чтобы сохранить соотношение между коэффициентами и обеспечить корректный сурбет.
    /// - Returns: Обновленные итоговые данные и строки.
    func calculateTotal() -> (TotalRow?, [Row]?) {
        var total = self.total
        let rows = calculateRowsBetSizesAndIncomes(total: total, rows: self.rows)
        let profitPercentage = (100 / surebetValue) - 100
        total.profitPercentage = profitPercentage.formatToString(isPercent: true)
        return (total, rows)
    }

    /// Обновляет размеры ставок и доходы для каждой строки и пересчитывает итоговые данные.
    /// Используется, когда пользователь изменил размеры ставок в нескольких строках -
    /// итоговая ставка вычисляется как сумма всех ставок, а доходы пересчитываются для каждой строки.
    /// - Returns: Обновленные итоговые данные и строки.
    func calculateRows() -> (TotalRow?, [Row]?) {
        var total = self.total
        var rows = self.rows
        let totalBetSize = displayedRowIndexes
            .compactMap { rows[$0].betSize.formatToDouble() }
            .reduce(0, +)
        displayedRowIndexes.forEach {
            let coefficient = rows[$0].coefficient.formatToDouble()
            let betSize = rows[$0].betSize.formatToDouble()
            if let coefficient, let betSize {
                rows[$0].income = calculateIncome(
                    coefficient: coefficient,
                    betSize: betSize,
                    totalBetSize: totalBetSize
                )
            }
        }
        total.betSize = totalBetSize.formatToString()
        total.profitPercentage = calculateProfitPercentage(totalBetSize: totalBetSize)
        return (total, rows)
    }

    /// Вычисляет данные для конкретной строки и обновляет итоговые данные и остальные строки.
    /// Используется, когда пользователь изменил размер ставки в одной строке -
    /// итоговая ставка пересчитывается так, чтобы сохранить пропорции сурбета,
    /// а остальные строки обновляются пропорционально.
    /// - Parameter id: Индекс строки, для которой выполняются вычисления.
    /// - Returns: Обновленные итоговые данные и строки.
    func calculateSpecificRow(_ id: Int) -> (TotalRow?, [Row]?) {
        var total = self.total
        var rows = self.rows
        let coefficient = rows[id].coefficient.formatToDouble()
        let betSize = rows[id].betSize.formatToDouble()
        if let coefficient, let betSize {
            let totalBetSize = (betSize / (1 / coefficient / surebetValue))
            total.betSize = totalBetSize.formatToString()
            total.profitPercentage = calculateProfitPercentage(totalBetSize: totalBetSize)
        }
        rows = calculateRowsBetSizesAndIncomes(total: total, rows: rows)
        return (total, rows)
    }

    /// Корректирует размеры ставок и доходы на основе итогового размера ставки и коэффициента каждой строки.
    /// Используется для пропорционального распределения итоговой ставки между строками
    /// в соответствии с их коэффициентами, чтобы сохранить корректность сурбета.
    /// - Parameters:
    ///   - total: Текущие итоговые данные.
    ///   - rows: Строки для обновления.
    /// - Returns: Обновленные строки с новыми размерами ставок и доходами.
    func calculateRowsBetSizesAndIncomes(total: TotalRow, rows: [Row]) -> [Row] {
        var updatedRows = rows
        displayedRowIndexes.forEach { index in
            let coefficient = rows[index].coefficient.formatToDouble()
            let totalBetSize = total.betSize.formatToDouble()
            if let coefficient, let totalBetSize {
                let betSize = 1 / coefficient / surebetValue * totalBetSize
                updatedRows[index].betSize = betSize.formatToString()
                updatedRows[index].income = calculateIncome(
                    coefficient: coefficient,
                    betSize: betSize,
                    totalBetSize: totalBetSize
                )
            }
        }
        return updatedRows
    }

    /// Вычисляет и форматирует процент прибыли на основе итогового размера ставки.
    /// Процент прибыли показывает, насколько выгодна комбинация ставок (положительное значение означает прибыль).
    /// - Parameter totalBetSize: Итоговый размер всех ставок.
    /// - Returns: Отформатированный процент прибыли в виде строки.
    func calculateProfitPercentage(totalBetSize: Double) -> String {
        let profitPercentage = (100 / surebetValue) - 100
        return profitPercentage.formatToString(isPercent: true)
    }

    /// Вычисляет и форматирует доход для конкретной ставки.
    /// Доход рассчитывается как разница между выигрышем (коэффициент × размер ставки) и общим размером всех ставок.
    /// Показывает, сколько можно заработать, если выиграет именно эта ставка.
    /// - Parameters:
    ///   - coefficient: Коэффициент для ставки.
    ///   - betSize: Размер ставки.
    ///   - totalBetSize: Общий размер всех ставок.
    /// - Returns: Отформатированный доход в виде строки.
    func calculateIncome(
        coefficient: Double,
        betSize: Double,
        totalBetSize: Double
    ) -> String {
        let winning = coefficient * betSize
        let income = winning - totalBetSize
        return income.formatToString()
    }

    /// Сбрасывает только вычисляемые поля при невалидном вводе.
    /// Не изменяет поля ввода (betSize/coefficient/total.betSize).
    func resetDerivedValues() -> (TotalRow?, [Row]?) {
        var total = self.total
        var rows = self.rows

        total.profitPercentage = TotalRow().profitPercentage
        rows.indices.forEach { index in
            rows[index].income = Row(id: rows[index].id).income
        }

        switch selectedRow {
        case .total:
            displayedRowIndexes.forEach { index in
                rows[index].betSize.removeAll()
            }
        case let .row(id):
            total.betSize.removeAll()
            displayedRowIndexes.forEach { index in
                if index != id {
                    rows[index].betSize.removeAll()
                }
            }
        case .none:
            total.betSize.removeAll()
        }

        return (total, rows)
    }
}
