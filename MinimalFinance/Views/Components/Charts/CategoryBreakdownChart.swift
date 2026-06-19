import SwiftUI
import Charts

struct CategoryBreakdownChart: View {
    let categories: [CategoryChartItem]

    var body: some View {
        Group {
            if categories.isEmpty {
                Text("Add expenses to see categories")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            } else {
                Chart(categories) { item in
                    BarMark(
                        x: .value("Category", item.name),
                        y: .value("Spent", item.total.chartValue)
                    )
                    .foregroundStyle(AppTheme.expenseColor)
                    .annotation(position: .top, alignment: .center, spacing: 2) {
                        Text(item.total.chartCurrencyLabel)
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

#Preview {
    CategoryBreakdownChart(categories: [
        CategoryChartItem(id: "Food", name: "Food", total: 320),
        CategoryChartItem(id: "Rent", name: "Rent", total: 1200),
        CategoryChartItem(id: "Transport", name: "Transport", total: 85)
    ])
    .frame(height: 200)
    .padding()
}
