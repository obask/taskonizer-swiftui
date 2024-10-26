import SwiftUI

// View to Add a New Task
struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State private var title: String = ""
    @State private var selectedCategory: TaskCategory = .inbox

    var body: some View {
        NavigationView {
            Form {
                TextField("Task Title", text: $title)
                
                Picker("Category", selection: $selectedCategory) {
                    ForEach(TaskCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
            }
            .navigationTitle("Add New Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addItem()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addItem() {
        let newItem = Item(title: title, timestamp: Date(), isCompleted: false, category: selectedCategory)
        modelContext.insert(newItem)
        try? modelContext.save()
    }
}
