import SwiftUI
import SwiftData

struct CategoryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    private let categoryToEdit: Category?

    @State private var name = ""
    @FocusState private var isNameFocused: Bool

    init(categoryToEdit: Category? = nil) {
        self.categoryToEdit = categoryToEdit
    }

    private var isEditing: Bool {
        categoryToEdit != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .focused($isNameFocused)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                isNameFocused = true
                            }
                        )
                }
            }
            .navigationTitle(isEditing ? "Edit category" : "Add category")
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
            .onAppear {
                if let categoryToEdit {
                    name = categoryToEdit.name
                }
                isNameFocused = true
            }
        }
    }

    private var canSave: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }

        let duplicate = categories.contains { category in
            category.persistentModelID != categoryToEdit?.persistentModelID
                && category.name.caseInsensitiveCompare(trimmed) == .orderedSame
        }
        return !duplicate
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)

        if let categoryToEdit {
            categoryToEdit.name = trimmed
        } else {
            let nextSortOrder = (categories.map(\.sortOrder).max() ?? -1) + 1
            let category = Category(name: trimmed, isBuiltIn: false, sortOrder: nextSortOrder)
            modelContext.insert(category)
        }

        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    CategoryFormView()
        .modelContainer(PreviewSampleData.container)
}
