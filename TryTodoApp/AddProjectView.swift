import SwiftUI

struct AddProjectView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var projectName: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Project Name", text: $projectName)
            }
            .navigationTitle("New Project")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addProject()
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

    private func addProject() {
        guard !projectName.isEmpty else { return }
        let newProject = Project(name: projectName)
        modelContext.insert(newProject)
        try? modelContext.save()
    }
}
