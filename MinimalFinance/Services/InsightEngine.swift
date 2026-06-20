import Foundation

struct CategoryBreakdown: Identifiable {
    let id: String
    let name: String
    let total: Decimal
}

typealias CategoryChartItem = CategoryBreakdown

struct InsightSnapshot {
    let weekTotal: Decimal
    let monthTotal: Decimal
    let yearToDateTotal: Decimal
    let categoryBreakdown: [CategoryBreakdown]
    let recurringTotal: Decimal
    let variableTotal: Decimal
    let monthIncome: Decimal
    let monthNet: Decimal
}

struct MonthlyFinancialShape {
    let income: Decimal
    let fixedPlanned: Decimal
    let variable: Decimal
    let savings: Decimal
    let totalExpenses: Decimal

    var hasData: Bool {
        income > 0 || totalExpenses > 0 || fixedPlanned > 0
    }
}

struct MonthComparisonSlice: Identifiable {
    let id: String
    let label: String
    let income: Decimal
    let expenses: Decimal
    let leftover: Decimal
}

struct BalanceTrendPoint: Identifiable {
    let id: Date
    let month: Date
    let net: Decimal
}

enum InsightEngine {
    static func snapshot(
        transactions: [Transaction],
        recurringExpenses: [RecurringExpense],
        now: Date = .now
    ) -> InsightSnapshot {
        let calendar = Calendar.current

        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let yearStart = calendar.dateInterval(of: .year, for: now)?.start ?? now

        let weekExpenses = sumExpenses(transactions.filter { $0.date >= weekStart })
        let monthExpenses = sumExpenses(transactions.filter { $0.date >= monthStart })
        let yearExpenses = sumExpenses(transactions.filter { $0.date >= yearStart })
        let monthIncome = sumIncome(transactions.filter { $0.date >= monthStart })

        let categoryBreakdown = categoryBreakdown(
            transactions: transactions,
            monthStart: monthStart,
            monthEnd: calendar.date(byAdding: .month, value: 1, to: monthStart)
        )

        let activeRecurring = recurringExpenses.filter(\.isActive)
        let recurringTotal = activeRecurring.reduce(Decimal.zero) { $0 + monthlyEquivalent(for: $1) }
        let variableTotal = max(monthExpenses - min(recurringTotal, monthExpenses), 0)

        return InsightSnapshot(
            weekTotal: weekExpenses,
            monthTotal: monthExpenses,
            yearToDateTotal: yearExpenses,
            categoryBreakdown: categoryBreakdown,
            recurringTotal: recurringTotal,
            variableTotal: variableTotal,
            monthIncome: monthIncome,
            monthNet: monthIncome - monthExpenses
        )
    }

    static func monthlyFinancialShape(
        transactions: [Transaction],
        recurringExpenses: [RecurringExpense],
        for month: Date = .now
    ) -> MonthlyFinancialShape {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else {
            return MonthlyFinancialShape(income: 0, fixedPlanned: 0, variable: 0, savings: 0, totalExpenses: 0)
        }

        let monthTransactions = transactions.filter { monthInterval.contains($0.date) }
        let income = sumIncome(monthTransactions)
        let totalExpenses = sumExpenses(monthTransactions)
        let fixedPlanned = recurringExpenses
            .filter(\.isActive)
            .reduce(Decimal.zero) { $0 + monthlyEquivalent(for: $1) }
        let fixedInSpend = min(fixedPlanned, totalExpenses)
        let variable = max(totalExpenses - fixedInSpend, 0)
        let savings = income - totalExpenses

        return MonthlyFinancialShape(
            income: income,
            fixedPlanned: fixedPlanned,
            variable: variable,
            savings: savings,
            totalExpenses: totalExpenses
        )
    }

    static func monthComparison(
        transactions: [Transaction],
        recurringExpenses: [RecurringExpense],
        now: Date = .now
    ) -> [MonthComparisonSlice] {
        let calendar = Calendar.current
        guard let thisMonthStart = calendar.dateInterval(of: .month, for: now)?.start else { return [] }

        let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: thisMonthStart) ?? thisMonthStart

        let thisShape = monthlyFinancialShape(
            transactions: transactions,
            recurringExpenses: recurringExpenses,
            for: thisMonthStart
        )
        let lastShape = monthlyFinancialShape(
            transactions: transactions,
            recurringExpenses: recurringExpenses,
            for: lastMonthStart
        )

        var averageIncome = Decimal.zero
        var averageExpenses = Decimal.zero
        var averageLeftover = Decimal.zero

        for offset in 1...3 {
            guard let monthStart = calendar.date(byAdding: .month, value: -offset, to: thisMonthStart) else { continue }
            let shape = monthlyFinancialShape(
                transactions: transactions,
                recurringExpenses: recurringExpenses,
                for: monthStart
            )
            averageIncome += shape.income
            averageExpenses += shape.totalExpenses
            averageLeftover += shape.savings
        }

        let divisor = Decimal(3)
        averageIncome /= divisor
        averageExpenses /= divisor
        averageLeftover /= divisor

        return [
            MonthComparisonSlice(
                id: "this",
                label: "This month",
                income: thisShape.income,
                expenses: thisShape.totalExpenses,
                leftover: thisShape.savings
            ),
            MonthComparisonSlice(
                id: "last",
                label: "Last month",
                income: lastShape.income,
                expenses: lastShape.totalExpenses,
                leftover: lastShape.savings
            ),
            MonthComparisonSlice(
                id: "avg",
                label: "Avg",
                income: averageIncome,
                expenses: averageExpenses,
                leftover: averageLeftover
            )
        ]
    }

    static func categoryBreakdown(
        transactions: [Transaction],
        monthStart: Date,
        monthEnd: Date? = nil,
        limit: Int = 5
    ) -> [CategoryBreakdown] {
        let end = monthEnd ?? Calendar.current.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
        let monthExpenses = transactions.filter {
            $0.kind == .expense && $0.date >= monthStart && $0.date < end
        }

        var categoryTotals: [String: Decimal] = [:]
        for transaction in monthExpenses {
            let name = transaction.category?.name ?? "Other"
            categoryTotals[name, default: 0] += transaction.amount
        }

        let sorted = categoryTotals
            .map { CategoryBreakdown(id: $0.key, name: $0.key, total: $0.value) }
            .sorted { $0.total > $1.total }
            .filter { $0.name != "Other" }

        guard sorted.count > limit else { return sorted }

        let top = Array(sorted.prefix(limit))
        let remainderTotal = sorted.dropFirst(limit).reduce(Decimal.zero) { $0 + $1.total }
        if remainderTotal > 0 {
            return top + [CategoryBreakdown(id: "More", name: "More", total: remainderTotal)]
        }
        return top
    }

    static func balanceTrend(
        transactions: [Transaction],
        months: Int = 6,
        now: Date = .now
    ) -> [BalanceTrendPoint] {
        let calendar = Calendar.current
        guard let currentMonthStart = calendar.dateInterval(of: .month, for: now)?.start else { return [] }

        return (0..<months).reversed().compactMap { offset in
            guard let monthStart = calendar.date(byAdding: .month, value: -offset, to: currentMonthStart),
                  let monthInterval = calendar.dateInterval(of: .month, for: monthStart) else {
                return nil
            }

            let monthTransactions = transactions.filter { monthInterval.contains($0.date) }
            let income = sumIncome(monthTransactions)
            let expenses = sumExpenses(monthTransactions)

            return BalanceTrendPoint(id: monthStart, month: monthStart, net: income - expenses)
        }
    }

    static func monthlyEquivalent(for expense: RecurringExpense) -> Decimal {
        switch expense.cadence {
        case .weekly:
            return expense.amount * Decimal(string: "4.33")!
        case .monthly:
            return expense.amount
        case .quarterly:
            return expense.amount / 3
        case .yearly:
            return expense.amount / 12
        }
    }

    private static func sumExpenses(_ transactions: [Transaction]) -> Decimal {
        transactions.filter { $0.kind == .expense }.reduce(Decimal.zero) { $0 + $1.amount }
    }

    private static func sumIncome(_ transactions: [Transaction]) -> Decimal {
        transactions.filter { $0.kind == .income }.reduce(Decimal.zero) { $0 + $1.amount }
    }
}
