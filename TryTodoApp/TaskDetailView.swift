import SwiftUI

struct TaskDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss  // Dismiss environment action
    @Bindable var item: Item

    var body: some View {
        Form {
            TextField("Task Title", text: $item.title)
            
            Toggle("Completed", isOn: $item.isCompleted)
            
            Picker("Category", selection: $item.category) {
                ForEach(TaskCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
        }
        .navigationTitle("Edit Task")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveChanges()
                }
            }
        }
    }

    private func saveChanges() {
        try? modelContext.save()
        dismiss()  // Dismisses the view and returns to the previous one
    }
}
