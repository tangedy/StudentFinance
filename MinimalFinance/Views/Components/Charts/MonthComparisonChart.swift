import SwiftUI
import Charts

private struct ComparisonBar: Identifiable {
    let id: String
    let period: String
    let metric: String
    let value: Decimal

    var color: Color {
        ChartColors.forMetric(metric)
    }
}

struct MonthComparisonChart: View {
    let slices: [MonthComparisonSlice]

    private var bars: [ComparisonBar] {
        slices.flatMap { slice in
            [
                ComparisonBar(id: "\(slice.id)-income", period: slice.label, metric: "Income", value: slice.income),
                ComparisonBar(id: "\(slice.id)-expenses", period: slice.label, metric: "Expenses", value: slice.expenses),
                ComparisonBar(id: "\(slice.id)-leftover", period: slice.label, metric: "Savings", value: slice.leftover)
            ]
        }
    }

    private var hasData: Bool {
        bars.contains { $0.value != 0 }
    }

    var body: some View {
        Group {
            if !hasData {
                Text("Add transactions to compare months")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            } else {
                Chart(bars) { bar in
                    BarMark(
                        x: .value("Period", bar.period),
                        y: .value("Amount", bar.value.chartValue)
                    )
                    .foregroundStyle(bar.color)
                    .position(by: .value("Metric", bar.metric))
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
                .chartLegend(position: .bottom, alignment: .leading, spacing: 12)
                .chartContentInsets()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
}

#Preview {
    MonthComparisonChart(slices: [
        MonthComparisonSlice(id: "this", label: "This month", income: 3000, expenses: 2000, leftover: 1000),
        MonthComparisonSlice(id: "last", label: "Last month", income: 2800, expenses: 2100, leftover: 700),
        MonthComparisonSlice(id: "avg", label: "Avg", income: 2900, expenses: 2050, leftover: 850)
    ])
    .frame(height: 200)
    .padding()
}
