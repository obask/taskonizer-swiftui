import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: Item
    @Query private var projects: [Project]  // Fetches available projects
    @State private var isAddingProject = false  // Controls showing the add project sheet

    var body: some View {
        Form {
            TextField("Task Title", text: $item.title)
            Toggle("Completed", isOn: $item.isCompleted)
            Picker("Category", selection: $item.category) {
                ForEach(TaskCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }

            // Project Picker
            Picker("Project", selection: $item.project) {
                Text("None").tag(nil as Project?)  // Option for no project
                ForEach(projects) { project in
                    Text(project.name).tag(project as Project?)
                }
            }

            // Button to add a new project
            Button("Add New Project") {
                isAddingProject = true  // Show the add project sheet
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
        .sheet(isPresented: $isAddingProject) {
            AddProjectView()
        }
    }

    private func saveChanges() {
        try? modelContext.save()
        dismiss()
    }
}
