import SwiftUI
import SwiftData
import AppKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @Query private var projects: [Project]
    @State private var selectedItemID: UUID?
    @State private var editingItemID: UUID?  // Track the item being edited
    @State private var editedTitle: String = ""  // Temporary storage for editing
    @State private var expandedTaskID: UUID?  // Track which task is expanded for Things 3-like behavior

    var body: some View {
            List(selection: $selectedItemID) {
                // Section for items without a project
                if !itemsWithoutProject.isEmpty {
                    Section(header: Text("No Project")) {
                        ForEach(itemsWithoutProject) { item in
                            TaskRow(
                                item: item,
                                isExpanded: Binding(
                                    get: { expandedTaskID == item.id },
                                    set: { isExpanded in
                                        expandedTaskID = isExpanded ? item.id : nil
                                    }
                                ),
                                editedTitle: $editedTitle,
                                editingItemID: $editingItemID
                            )
                            .tag(item.id)
                        }
                    }
                }

                // Sections for items grouped by project
                ForEach(projects) { project in
                    let projectItems = itemsForProject(project)
                    if !projectItems.isEmpty {
                        Section(header: Text(project.name)) {
                            ForEach(projectItems) { item in
                                TaskRow(
                                    item: item,
                                    isExpanded: Binding(
                                        get: { expandedTaskID == item.id },
                                        set: { isExpanded in
                                            expandedTaskID = isExpanded ? item.id : nil
                                        }
                                    ),
                                    editedTitle: $editedTitle,
                                    editingItemID: $editingItemID
                                )
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
            .onAppear {
                setupKeyboardHandlers()
            }
            .onChange(of: selectedItemID) {
                if editingItemID != nil {
                    saveChanges()
                }
            }
        }
    }

    // MARK: - Keyboard Handlers

    private func setupKeyboardHandlers() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            handleKeyPress(event)
            return event
        }
    }

    private func handleKeyPress(_ event: NSEvent) {
        if event.keyCode == 36 {  // Enter key keyCode
            if let selectedItemID = selectedItemID {
                startEditing(itemID: selectedItemID)
            }
        }
    }

    // MARK: - Helper Functions

    private func startEditing(item: Item) {
        if editingItemID == item.id {
            // Already editing this item, so do not override editedTitle
            return
        }
        editingItemID = item.id
        editedTitle = item.title
    }

    private func startEditing(itemID: UUID) {
        if let item = items.first(where: { $0.id == itemID }) {
            startEditing(item: item)
        }
    }

    private func saveChanges() {
        if let editingItemID = editingItemID, let itemIndex = items.firstIndex(where: { $0.id == editingItemID }) {
            items[itemIndex].title = editedTitle
            try? modelContext.save()
        }
        editingItemID = nil
        editedTitle = ""
    }

    private func addItem() {
        let newItem = Item(title: "New Task", timestamp: Date(), isCompleted: false, project: nil)
        modelContext.insert(newItem)
        try? modelContext.save()
        selectedItemID = newItem.id
    }

    private var itemsWithoutProject: [Item] {
        items.filter { $0.project == nil }
    }

    private func itemsForProject(_ project: Project) -> [Item] {
        items.filter { $0.project?.id == project.id }
    }
}
