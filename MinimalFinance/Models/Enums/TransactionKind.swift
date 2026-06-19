import Foundation

enum TransactionKind: String, Codable, CaseIterable {
    case expense
    case income

    var label: String {
        switch self {
        case .expense: "Expense"
        case .income: "Income"
        }
    }
}
