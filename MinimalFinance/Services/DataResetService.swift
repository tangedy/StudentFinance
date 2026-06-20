import Foundation
import SwiftData

enum DataResetService {
    static func clearAllData(modelContext: ModelContext) {
        deleteAll(CategoryRule.self, modelContext: modelContext)
        deleteAll(Transaction.self, modelContext: modelContext)
        deleteAll(ImportBatch.self, modelContext: modelContext)
        deleteAll(RecurringExpense.self, modelContext: modelContext)
        deleteAll(Category.self, modelContext: modelContext)

        try? modelContext.save()
        SeedDataService.seedIfNeeded(modelContext: modelContext)
    }

    private static func deleteAll<T: PersistentModel>(
        _ type: T.Type,
        modelContext: ModelContext
    ) {
        let items = (try? modelContext.fetch(FetchDescriptor<T>())) ?? []
        for item in items {
            modelContext.delete(item)
        }
    }
}
