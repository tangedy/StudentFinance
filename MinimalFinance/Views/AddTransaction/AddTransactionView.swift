import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    private let transactionToEdit: Transaction?

    @FocusState private var focusedField: Field?

    @State private var amountText = ""
    @State private var merchant = ""
    @State private var selectedCategory: Category?
    @State private var date = Date.now
    @State private var note = ""

    private enum Field: Hashable {
        case amount
        case merchant
        case note
    }

    init(transactionToEdit: Transaction? = nil) {
        self.transactionToEdit = transactionToEdit
    }

    private var isEditing: Bool {
        transactionToEdit != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    formTextField("Amount", text: $amountText, field: .amount, keyboardType: .decimalPad)
                        .onChange(of: amountText) { _, newValue in
                            let filtered = Self.filterAmountInput(newValue)
                            if filtered != newValue {
                                amountText = filtered
                            }
                        }
                    formTextField("Merchant or description", text: $merchant, field: .merchant)
                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(Optional<Category>.none)
                        ForEach(categories) { category in
                            Text(category.name).tag(Optional(category))
                        }
                    }
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    formTextField("Note (optional)", text: $note, field: .note)
                }
            }
            .navigationTitle(isEditing ? "Edit transaction" : "Add transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
            .onAppear(perform: loadExistingTransaction)
        }
    }

    private func formTextField(
        _ placeholder: String,
        text: Binding<String>,
        field: Field,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboardType)
            .focused($focusedField, equals: field)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .simultaneousGesture(
                TapGesture().onEnded {
                    focusedField = field
                }
            )
    }

    private func loadExistingTransaction() {
        guard let transactionToEdit else { return }
        amountText = NSDecimalNumber(decimal: transactionToEdit.amount).stringValue
        merchant = transactionToEdit.merchant
        selectedCategory = transactionToEdit.category
        date = transactionToEdit.date
        note = transactionToEdit.note ?? ""
    }

    private static func filterAmountInput(_ value: String) -> String {
        var result = ""
        var hasDecimalSeparator = false

        for character in value {
            if character.isNumber {
                result.append(character)
            } else if (character == "." || character == ",") && !hasDecimalSeparator {
                hasDecimalSeparator = true
                result.append(".")
            }
        }

        return result
    }

    private var canSave: Bool {
        !merchant.trimmingCharacters(in: .whitespaces).isEmpty
            && Decimal(string: amountText.replacingOccurrences(of: ",", with: "")) != nil
    }

    private func save() {
        guard let amount = Decimal(string: amountText.replacingOccurrences(of: ",", with: "")) else { return }

        let trimmedMerchant = merchant.trimmingCharacters(in: .whitespaces)
        let trimmedNote = note.trimmingCharacters(in: .whitespaces)

        if let transactionToEdit {
            transactionToEdit.amount = amount
            transactionToEdit.merchant = trimmedMerchant
            transactionToEdit.category = selectedCategory
            transactionToEdit.date = date
            transactionToEdit.note = trimmedNote.isEmpty ? nil : trimmedNote
        } else {
            let transaction = Transaction(
                amount: amount,
                date: date,
                merchant: trimmedMerchant,
                category: selectedCategory,
                source: .manual,
                note: trimmedNote.isEmpty ? nil : trimmedNote
            )
            modelContext.insert(transaction)
        }

        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddTransactionView()
        .modelContainer(PreviewSampleData.container)
}
