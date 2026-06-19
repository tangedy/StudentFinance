import SwiftUI

private enum HomeChartPage: Int, CaseIterable {
    case snapshot
    case comparison
    case categories
    case balance

    var title: String {
        switch self {
        case .snapshot: "Monthly shape"
        case .comparison: "Comparison"
        case .categories: "Categories"
        case .balance: "Balance"
        }
    }
}

struct HomeChartCarousel: View {
    let monthlyShape: MonthlyFinancialShape
    let comparisonSlices: [MonthComparisonSlice]
    let categoryItems: [CategoryChartItem]
    let balancePoints: [BalanceTrendPoint]

    @State private var selectedPage = 0

    private let chartHeight: CGFloat = 210

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(HomeChartPage(rawValue: selectedPage)?.title ?? "Overview")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)

            TabView(selection: $selectedPage) {
                MonthlySnapshotChart(shape: monthlyShape)
                    .tag(HomeChartPage.snapshot.rawValue)

                MonthComparisonChart(slices: comparisonSlices)
                    .tag(HomeChartPage.comparison.rawValue)

                CategoryBreakdownChart(categories: categoryItems)
                    .tag(HomeChartPage.categories.rawValue)

                BalanceTrendChart(points: balancePoints)
                    .tag(HomeChartPage.balance.rawValue)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: chartHeight)

            HStack(spacing: 6) {
                Spacer()
                ForEach(HomeChartPage.allCases, id: \.rawValue) { page in
                    Circle()
                        .fill(
                            selectedPage == page.rawValue
                                ? AppTheme.primaryText.opacity(0.7)
                                : AppTheme.secondaryText.opacity(0.25)
                        )
                        .frame(width: 6, height: 6)
                }
                Spacer()
            }
            .padding(.top, 2)
        }
    }
}

#Preview {
    HomeChartCarousel(
        monthlyShape: MonthlyFinancialShape(
            income: 3000,
            fixedPlanned: 1200,
            variable: 800,
            savings: 1000,
            totalExpenses: 2000
        ),
        comparisonSlices: [],
        categoryItems: [],
        balancePoints: []
    )
    .padding()
}
