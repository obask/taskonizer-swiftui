import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @Query private var projects: [Project]  // Fetch available projects
    @State private var selectedCategory: TaskCategory = .inbox
    @State private var selectedItemID: UUID?
    @State private var singleSelection: UUID?

    var body: some View {
        NavigationSplitView {
            // Sidebar with task categories
            List(TaskCategory.allCases, id: \.self, selection: $selectedCategory) { category in
                Label(category.rawValue, systemImage: category.iconName)
            }
            .navigationTitle("Categories")
        } detail: {
            // Middle pane with list of todos grouped by project
            List(selection: $selectedItemID) {
                // Section for items without a project
                if !itemsWithoutProject.isEmpty {
                    Section(header: Text("No Project")) {
                        ForEach(itemsWithoutProject) { item in
                            Text(item.title)
                                .strikethrough(item.isCompleted)
                                .tag(item.id)
                        }
                    }
                }

                // Sections for items grouped by project
                ForEach(projects) { project in
                    Section(header: Text(project.name)) {
                        ForEach(itemsForProject(project)) { item in
                            Text(item.title)
                                .strikethrough(item.isCompleted)
                                .tag(item.id)
                        }
                    }
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: addItem) {
                        Label("Add Task", systemImage: "plus")
                    }
                }
            }
        }
        .onAppear {
            // Initialize the selected item when the view appears
            selectedItemID = filteredItems.first?.id
        }
    }

    // MARK: - Helper Functions

    private func addItem() {
        let newItem = Item(title: "New Task", timestamp: Date(), isCompleted: false, category: selectedCategory)
        modelContext.insert(newItem)
        try? modelContext.save()
        
        // Update the selection to the new item
        selectedItemID = newItem.id
    }

    // Filtered items based on selected category and project status
    private var itemsWithoutProject: [Item] {
        items.filter { $0.category == selectedCategory && $0.project == nil }
    }

    private func itemsForProject(_ project: Project) -> [Item] {
        items.filter { $0.category == selectedCategory && $0.project?.id == project.id }
    }

    private var filteredItems: [Item] {
        items.filter { $0.category == selectedCategory }
    }
}
