import Foundation

/// Структура для управления вычислениями в калькуляторе сурбетов.
/// Использует различные методы вычислений в зависимости от того, какое поле было изменено пользователем.
struct Calculator: Sendable {
    // MARK: - Properties

    /// Итоговая строка с общим размером ставки и процентом прибыли.
    let total: TotalRow
    /// Строки с данными о ставках по идентификаторам.
    let rowsById: [RowID: Row]
    /// Общий порядок строк (для UI и стабильности идентификаторов).
    let orderedRowIds: [RowID]
    /// Упорядоченный список активных строк для расчётов.
    let activeRowIds: [RowID]
    /// Выбранная строка для вычислений.
    let selection: Selection

    // MARK: - Public Methods

    /// Выполняет вычисления на основе выбранного метода и обновляет итоговые данные и строки.
    /// Метод вычислений определяется автоматически на основе того, какое поле было изменено:
    /// - Если изменена итоговая ставка - пересчитываются все строки пропорционально.
    /// - Если изменена ставка в конкретной строке - пересчитываются итоговая ставка и остальные строки.
    /// - Если изменены ставки в нескольких строках - пересчитывается итоговая ставка.
    /// - Returns: Результат расчёта (обновление, сброс производных, no-op или ошибка ввода).
    func calculate() -> CalculationResult {
        if let validationResult = validateInput() {
            return validationResult
        }

        if activeRowIds.count < CalculatorConstants.minRowCount {
            return .resetDerived(resetDerivedValues())
        }

        switch calculationMethod {
        case .total:
            return .updated(calculateTotal())
        case .rows:
            return .updated(calculateRows())
        case let .row(id):
            return .updated(calculateSpecificRow(id))
        case .none:
            return .resetDerived(resetDerivedValues())
        }
    }
}

// MARK: - Private Methods

private extension Calculator {
    func validateInput() -> CalculationResult? {
        let orderedSet = Set(orderedRowIds)
        if orderedSet.count != orderedRowIds.count {
            return .invalidInput(.duplicateRowIds)
        }

        let activeSet = Set(activeRowIds)
        if activeSet.count != activeRowIds.count {
            return .invalidInput(.duplicateRowIds)
        }

        for id in activeRowIds where rowsById[id] == nil {
            return .invalidInput(.missingRow(id))
        }

        if case let .row(id) = selection, rowsById[id] == nil {
            return .invalidInput(.selectionRowMissing(id))
        }

        return nil
    }

    /// Вычисляет значение сурбета как обратную величину суммы обратных величин коэффициентов.
    /// Используется для определения, является ли комбинация ставок выигрышной (значение < 1.0).
    /// Формула: 1 / (1/k1 + 1/k2 + ... + 1/kn), где k1, k2, ..., kn - коэффициенты активных строк.
    var surebetValue: Double {
        activeRowIds
            .compactMap { rowsById[$0]?.coefficient.formatToDouble() }
            .reduce(0) { $0 + (1 / $1) }
    }

    /// Проверяет, что все активные строки имеют валидные и непустые размеры ставок.
    /// Используется для определения возможности вычисления итоговой ставки из суммы ставок по строкам.
    var hasValidBetSizes: Bool {
        activeRowIds
            .compactMap { rowsById[$0]?.betSize }
            .allSatisfy { $0.isValidDouble() && !$0.isEmpty }
    }

    /// Проверяет, что все активные коэффициенты могут быть преобразованы в числа и являются положительными.
    /// Необходимо для корректного вычисления сурбета,
    /// так как отрицательные или нулевые коэффициенты делают вычисления невозможными.
    var hasValidCoefficients: Bool {
        activeRowIds
            .compactMap { rowsById[$0]?.coefficient }
            .allSatisfy { $0.formatToDouble() ?? 0 >= 1 }
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
        switch selection {
        case .total where total.betSize.isValidDouble() && !total.betSize.isEmpty:
            return .total
        case let .row(id):
            if let row = rowsById[id], row.betSize.isValidDouble() && !row.betSize.isEmpty {
                return .row(id)
            }
            return .none
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
    func calculateTotal() -> CalculationOutput {
        var total = self.total
        let rowsById = calculateRowsBetSizesAndIncomes(total: total, rowsById: self.rowsById)
        let profitPercentage = (100 / surebetValue) - 100
        total.profitPercentage = profitPercentage.formatToString(isPercent: true)
        return CalculationOutput(total: total, rowsById: rowsById)
    }

    /// Обновляет размеры ставок и доходы для каждой строки и пересчитывает итоговые данные.
    /// Используется, когда пользователь изменил размеры ставок в нескольких строках -
    /// итоговая ставка вычисляется как сумма всех ставок, а доходы пересчитываются для каждой строки.
    /// - Returns: Обновленные итоговые данные и строки.
    func calculateRows() -> CalculationOutput {
        var total = self.total
        var rowsById = self.rowsById
        let totalBetSize = activeRowIds
            .compactMap { rowsById[$0]?.betSize.formatToDouble() }
            .reduce(0, +)
        for id in activeRowIds {
            guard var row = rowsById[id] else { continue }
            let coefficient = row.coefficient.formatToDouble()
            let betSize = row.betSize.formatToDouble()
            if let coefficient, let betSize {
                row.income = calculateIncome(
                    coefficient: coefficient,
                    betSize: betSize,
                    totalBetSize: totalBetSize
                )
                rowsById[id] = row
            }
        }
        total.betSize = totalBetSize.formatToString()
        total.profitPercentage = calculateProfitPercentage(totalBetSize: totalBetSize)
        return CalculationOutput(total: total, rowsById: rowsById)
    }

    /// Вычисляет данные для конкретной строки и обновляет итоговые данные и остальные строки.
    /// Используется, когда пользователь изменил размер ставки в одной строке -
    /// итоговая ставка пересчитывается так, чтобы сохранить пропорции сурбета,
    /// а остальные строки обновляются пропорционально.
    /// - Parameter id: Идентификатор строки, для которой выполняются вычисления.
    /// - Returns: Обновленные итоговые данные и строки.
    func calculateSpecificRow(_ id: RowID) -> CalculationOutput {
        var total = self.total
        var rowsById = self.rowsById
        let coefficient = rowsById[id]?.coefficient.formatToDouble()
        let betSize = rowsById[id]?.betSize.formatToDouble()
        if let coefficient, let betSize {
            let totalBetSize = (betSize / (1 / coefficient / surebetValue))
            total.betSize = totalBetSize.formatToString()
            total.profitPercentage = calculateProfitPercentage(totalBetSize: totalBetSize)
        }
        rowsById = calculateRowsBetSizesAndIncomes(total: total, rowsById: rowsById)
        return CalculationOutput(total: total, rowsById: rowsById)
    }

    /// Корректирует размеры ставок и доходы на основе итогового размера ставки и коэффициента каждой строки.
    /// Используется для пропорционального распределения итоговой ставки между строками
    /// в соответствии с их коэффициентами, чтобы сохранить корректность сурбета.
    /// - Parameters:
    ///   - total: Текущие итоговые данные.
    ///   - rowsById: Строки для обновления.
    /// - Returns: Обновленные строки с новыми размерами ставок и доходами.
    func calculateRowsBetSizesAndIncomes(
        total: TotalRow,
        rowsById: [RowID: Row]
    ) -> [RowID: Row] {
        var updatedRowsById = rowsById
        for id in activeRowIds {
            guard var row = rowsById[id] else { continue }
            let coefficient = row.coefficient.formatToDouble()
            let totalBetSize = total.betSize.formatToDouble()
            if let coefficient, let totalBetSize {
                let betSize = 1 / coefficient / surebetValue * totalBetSize
                row.betSize = betSize.formatToString()
                row.income = calculateIncome(
                    coefficient: coefficient,
                    betSize: betSize,
                    totalBetSize: totalBetSize
                )
                updatedRowsById[id] = row
            }
        }
        return updatedRowsById
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
    func resetDerivedValues() -> CalculationOutput {
        var total = self.total
        var rowsById = self.rowsById

        total.profitPercentage = TotalRow().profitPercentage
        let rowIds = Array(rowsById.keys)
        for id in rowIds {
            if var row = rowsById[id] {
                row.income = Row(id: id).income
                rowsById[id] = row
            }
        }

        switch selection {
        case .total:
            for id in activeRowIds {
                guard var row = rowsById[id] else { continue }
                row.betSize.removeAll()
                rowsById[id] = row
            }
        case let .row(id):
            total.betSize.removeAll()
            for currentId in activeRowIds where currentId != id {
                guard var row = rowsById[currentId] else { continue }
                row.betSize.removeAll()
                rowsById[currentId] = row
            }
        case .none:
            total.betSize.removeAll()
        }

        return CalculationOutput(total: total, rowsById: rowsById)
    }
}
