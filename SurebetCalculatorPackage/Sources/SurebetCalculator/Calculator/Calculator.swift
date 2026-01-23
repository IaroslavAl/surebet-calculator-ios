import Foundation

/// A structure for managing betting calculations.
struct Calculator: Sendable {
    let total: TotalRow
    let rows: [Row]
    let selectedRow: RowType?
    let displayedRowIndexes: Range<Int>

    /// Performs calculations based on the selected method and updates totals and rows.
    /// - Returns: A tuple of updated total and rows.
    func calculate() -> (total: TotalRow?, rows: [Row]?) {
        switch calculationMethod {
        case .total:
            return calculateTotal()
        case .rows:
            return calculateRows()
        case let .row(id):
            return calculateSpecificRow(id)
        case .none:
            return (nil, nil)
        }
    }
}

private extension Calculator {
    /// The reciprocal of the sum of the reciprocals of the displayed rows' coefficients.
    var surebetValue: Double {
        rows[displayedRowIndexes]
            .compactMap { $0.coefficient.formatToDouble() }
            .reduce(0) { $0 + (1 / $1) }
    }

    /// Verifies that all displayed rows have valid and non-empty bet sizes.
    var hasValidBetSizes: Bool {
        rows[displayedRowIndexes]
            .map(\.betSize)
            .allSatisfy { $0.isValidDouble() && !$0.isEmpty }
    }

    /// Checks if all displayed coefficients can be converted to doubles and are positive.
    var hasValidCoefficients: Bool {
        rows[displayedRowIndexes]
            .map(\.coefficient)
            .allSatisfy { $0.formatToDouble() ?? 0 > 0 }
    }

    /// Determines the calculation method based on the current input validity.
    var calculationMethod: CalculationMethod? {
        guard hasValidCoefficients else {
            return .none
        }
        switch selectedRow {
        case .total where total.betSize.isValidDouble() && !total.betSize.isEmpty:
            return .total
        case let .row(id) where rows[id].betSize.isValidDouble():
            return .row(id)
        case .none where hasValidBetSizes:
            return .rows
        default:
            return .none
        }
    }

    /// Calculates total for all rows considering current bet sizes.
    /// - Returns: Updated total and rows.
    func calculateTotal() -> (TotalRow?, [Row]?) {
        var total = self.total
        let rows = calculateRowsBetSizesAndIncomes(total: total, rows: self.rows)
        let profitPercentage = (100 / surebetValue) - 100
        total.profitPercentage = profitPercentage.formatToString(isPercent: true)
        return (total, rows)
    }

    /// Updates bet sizes and incomes for each row and recalculates total accordingly.
    /// - Returns: Updated total and rows.
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

    /// Calculates for a specific row and updates total and other rows accordingly.
    /// - Parameter id: Index of the row.
    /// - Returns: Updated total and rows.
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

    /// Adjusts bet sizes and incomes based on total bet size and each row's coefficient.
    /// - Parameters:
    ///   - total: Current total info.
    ///   - rows: Rows to update.
    /// - Returns: Updated rows.
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

    /// Calculates and formats profit percentage from the total bet size.
    /// - Parameter totalBetSize: Total size of bets.
    /// - Returns: Formatted profit percentage.
    func calculateProfitPercentage(totalBetSize: Double) -> String {
        let profitPercentage = (100 / surebetValue) - 100
        return profitPercentage.formatToString(isPercent: true)
    }

    /// Calculates and formats income for a given bet.
    /// - Parameters:
    ///   - coefficient: Coefficient for the bet.
    ///   - betSize: Size of the bet.
    ///   - totalBetSize: Combined size of all bets.
    /// - Returns: Formatted income.
    func calculateIncome(
        coefficient: Double,
        betSize: Double,
        totalBetSize: Double
    ) -> String {
        let winning = coefficient * betSize
        let income = winning - totalBetSize
        return income.formatToString()
    }
}
