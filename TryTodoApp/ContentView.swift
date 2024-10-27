import SwiftUI
import SwiftData
import AppKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var selectedCategory: TaskCategory = .today
    @State private var editingItemID: UUID? = nil
    @State private var editingTitle: String = ""
    @State private var selectedItemID: UUID? = nil
    @FocusState private var focusedItemID: UUID?

    var body: some View {
        NavigationSplitView {
            List(TaskCategory.allCases, id: \.self, selection: $selectedCategory) { category in
                Label(category.rawValue, systemImage: category.iconName)
                    .badge(count(for: category))
            }
            .navigationTitle("Categories")
        } detail: {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(selectedCategory.rawValue)
                        .font(.title)
                        .bold()
                }
                .padding(.bottom, 10)
                    List {
                        ForEach(filteredItems) { item in
                            HStack {
                                Button(action: {
                                    toggleTaskCompletion(for: item)
                                }) {
                                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(item.isCompleted ? .green : .gray)
                                }

                                if editingItemID == item.id {
                                    TextField("Task Title", text: $editingTitle)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .focused($focusedItemID, equals: item.id)
                                        .onSubmit {
                                            saveChanges(for: item)
                                        }
                                        .onTapGesture {
                                            startEditing(item: item)
                                        }
                                        .onExitCommand {
                                            cancelEditing()
                                        }
                                        .onAppear {
                                            focusedItemID = item.id
                                        }
                                } else {
                                    Text(item.title)
                                        .strikethrough(item.isCompleted)
                                        .padding()
                                        .background(selectedItemID == item.id ? Color.blue.opacity(0.2) : Color.clear)
                                        .cornerRadius(8)
                                        .onTapGesture {
                                            selectedItemID = item.id
                                        }
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if editingItemID == nil {
                                    selectedItemID = item.id
                                }
                        }
                    }
                }
            }
            .padding()
            .onAppear {
                setupKeyboardHandlers()
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }

    // MARK: - Helper Functions

    private func addItem() {
        let newItem = Item(title: "New Task", timestamp: Date(), isCompleted: false, category: selectedCategory)
        modelContext.insert(newItem)  // Insert the new item into the model context
        try? modelContext.save()       // Save changes to persist the new item
    }
    
    private func setupKeyboardHandlers() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            handleKeyPress(event)
            return event
        }
    }

    private func handleKeyPress(_ event: NSEvent) {
        guard let currentIndex = filteredItems.firstIndex(where: { $0.id == selectedItemID }) else { return }
        
        switch event.keyCode {
        case 125: // Down Arrow Key
            let nextIndex = (currentIndex + 1) % filteredItems.count
            selectedItemID = filteredItems[nextIndex].id
        case 126: // Up Arrow Key
            let prevIndex = (currentIndex - 1 + filteredItems.count) % filteredItems.count
            selectedItemID = filteredItems[prevIndex].id
        case 36: // Enter Key
            if let selectedItem = filteredItems.first(where: { $0.id == selectedItemID }) {
                startEditing(item: selectedItem)
            }
        case 53: // Escape Key
            cancelEditing()
        default:
            break
        }
    }

    private func startEditing(item: Item) {
        editingItemID = item.id
        editingTitle = item.title
        focusedItemID = item.id
    }

    private func saveChanges(for item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].title = editingTitle
            try? modelContext.save()
        }
        editingItemID = nil
        focusedItemID = nil
    }

    private func cancelEditing() {
        editingItemID = nil
        editingTitle = ""
        focusedItemID = nil
    }

    private func toggleTaskCompletion(for item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
            try? modelContext.save()
        }
    }

    private var filteredItems: [Item] {
        switch selectedCategory {
        case .today:
            return items.filter { Calendar.current.isDateInToday($0.timestamp) }
        case .inbox:
            return items.filter { $0.category == .inbox }
        case .upcoming:
            return items.filter { $0.timestamp > Date() && $0.category == .upcoming }
        case .anytime:
            return items.filter { $0.category == .anytime }
        case .someday:
            return items.filter { $0.category == .someday }
        case .logbook:
            return items.filter { $0.isCompleted && $0.category == .logbook }
        case .trash:
            return items.filter { $0.category == .trash }
        }
    }

    private func count(for category: TaskCategory) -> Int {
        return filteredItems.count
    }
}
