import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("currencyCode") private var currencyCode = "USD"

    @State private var showClearConfirmation = false

    private let currencies = ["USD", "CAD", "EUR", "GBP"]

    var body: some View {
        Form {
            Section("General") {
                Picker("Currency", selection: $currencyCode) {
                    ForEach(currencies, id: \.self) { code in
                        Text(code).tag(code)
                    }
                }
            }

            Section("Data") {
                Button("Export data") {}
                Button("Backup") {}
                Button("Clear all data", role: .destructive) {
                    showClearConfirmation = true
                }
            }

            Section("Privacy") {
                Text("All data is stored locally on this device.")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Clear all data?",
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear everything", role: .destructive) {
                DataResetService.clearAllData(modelContext: modelContext)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Deletes all transactions, rules, and recurring expenses. Built-in categories are restored.")
        }
        .onAppear {
            SeedDataService.seedIfNeeded(modelContext: modelContext)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(PreviewSampleData.container)
}
