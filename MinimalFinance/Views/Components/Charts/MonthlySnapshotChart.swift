import SwiftUI
import Charts

struct MonthlySnapshotChart: View {
    let shape: MonthlyFinancialShape

    private var bars: [ChartBar] {
        ChartDataBuilder.snapshotBars(from: shape)
    }

    private var hasAnyValue: Bool {
        bars.contains { $0.value != 0 }
    }

    var body: some View {
        Group {
            if !hasAnyValue {
                chartEmptyState("Add transactions to see your month")
            } else {
                Chart(bars) { bar in
                    BarMark(
                        x: .value("Category", bar.label),
                        y: .value("Amount", bar.value.chartValue)
                    )
                    .foregroundStyle(bar.color)
                    .annotation(position: .top, alignment: .center, spacing: 2) {
                        Text(bar.value.chartCurrencyLabel)
                            .font(.caption2)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.secondary.opacity(0.15))
                        AxisValueLabel {
                            if let amount = value.as(Double.self) {
                                Text(Decimal(amount).chartCurrencyLabel)
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.caption2)
                    }
                }
                .chartLegend(.hidden)
                .chartContentInsets()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
}

private func chartEmptyState(_ message: String) -> some View {
    Text(message)
        .font(.caption)
        .foregroundStyle(AppTheme.secondaryText)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
}

#Preview {
    MonthlySnapshotChart(
        shape: MonthlyFinancialShape(
            income: 3000,
            fixedPlanned: 1200,
            variable: 800,
            savings: 1000,
            totalExpenses: 2000
        )
    )
    .frame(height: 200)
    .padding()
}
