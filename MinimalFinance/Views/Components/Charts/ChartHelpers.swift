import Foundation
import SwiftUI

extension Decimal {
    var chartValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }

    var chartCurrencyLabel: String {
        let code = UserDefaults.standard.string(forKey: "currencyCode") ?? "USD"
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: self)) ?? "$0"
    }
}

struct ChartBar: Identifiable {
    let id: String
    let label: String
    let value: Decimal

    var color: Color {
        ChartColors.forSnapshotBar(id: id, value: value)
    }
}

enum ChartDataBuilder {
    static func snapshotBars(from shape: MonthlyFinancialShape) -> [ChartBar] {
        [
            ChartBar(id: "income", label: "Income", value: shape.income),
            ChartBar(id: "fixed", label: "Fixed", value: shape.fixedPlanned),
            ChartBar(id: "variable", label: "Variable", value: shape.variable),
            ChartBar(id: "savings", label: "Savings", value: shape.savings)
        ]
    }
}

extension View {
    func chartContentInsets() -> some View {
        padding(.top, 14)
            .padding(.bottom, 4)
            .padding(.horizontal, 4)
    }
}
