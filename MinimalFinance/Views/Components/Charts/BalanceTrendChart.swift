import SwiftUI
import Charts

struct BalanceTrendChart: View {
    let points: [BalanceTrendPoint]

    private var hasData: Bool {
        points.contains { $0.net != 0 }
    }

    var body: some View {
        Group {
            if !hasData {
                Text("Add income and expenses to see balance")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            } else {
                Chart(points) { point in
                    AreaMark(
                        x: .value("Month", point.month, unit: .month),
                        y: .value("Net", point.net.chartValue)
                    )
                    .foregroundStyle(
                        point.net >= 0
                            ? AppTheme.incomeColor.opacity(0.15)
                            : AppTheme.expenseColor.opacity(0.15)
                    )

                    LineMark(
                        x: .value("Month", point.month, unit: .month),
                        y: .value("Net", point.net.chartValue)
                    )
                    .foregroundStyle(point.net >= 0 ? AppTheme.incomeColor : AppTheme.expenseColor)
                    .lineStyle(StrokeStyle(lineWidth: 2))
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
                    AxisMarks(values: .stride(by: .month)) { _ in
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
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

#Preview {
    BalanceTrendChart(points: [
        BalanceTrendPoint(id: Date(), month: Date(), net: 400),
        BalanceTrendPoint(id: Date(), month: Date(), net: -120),
        BalanceTrendPoint(id: Date(), month: Date(), net: 850)
    ])
    .frame(height: 200)
    .padding()
}
