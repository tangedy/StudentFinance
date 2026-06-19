import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    private var signedAmount: Decimal {
        transaction.kind == .expense ? -transaction.amount : transaction.amount
    }

    private var subtitle: String? {
        if transaction.kind == .income {
            return "Income"
        }
        return transaction.category?.name
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.merchant)
                    .font(.body)
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(signedAmount, format: .currency(code: UserDefaults.standard.string(forKey: "currencyCode") ?? "USD"))
                    .font(.body)
                    .fontWeight(.light)
                    .foregroundStyle(
                        transaction.kind == .income ? AppTheme.incomeColor : AppTheme.primaryText
                    )
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
