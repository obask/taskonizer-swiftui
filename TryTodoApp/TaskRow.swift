import SwiftUI
import SwiftData
import AppKit

struct TaskRow: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: Item
    var isEditing: Bool
    @Binding var editedTitle: String
    @Binding var editingItemID: UUID?  // Binding to reset editingItemID after commit
    @FocusState private var titleFieldIsFocused: Bool

    // Custom light gray background color to mimic systemGray6 on macOS
    private var editingBackgroundColor: Color {
        #if os(macOS)
        return Color.gray.opacity(0.15)
        #else
        return Color(.systemGray6)
        #endif
    }

    var body: some View {
        HStack(alignment: .top) {
            Button(action: toggleCompletion) {
                Image(systemName: item.isCompleted ? "checkmark.square" : "square")
                    .foregroundColor(item.isCompleted ? .green : .gray)
                    .imageScale(.large)
            }

            VStack(alignment: .leading) {
                if isEditing {
                    TextField("Edit Task", text: $editedTitle, onCommit: saveChanges)
                        .textFieldStyle(PlainTextFieldStyle())  // Plain style for better integration with background
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(editingBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .focused($titleFieldIsFocused)
                        .onAppear {
                            titleFieldIsFocused = true
                            moveCursorToEnd()
                        }
                } else {
                    Text(item.title)
                        .strikethrough(item.isCompleted)
                        .padding(.vertical, 4)
                        .font(.body)
                }
            }
            .padding(.leading, 5)

            Spacer()

            if isEditing {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.blue)
            }
        }
        .padding(8)
        .background(isEditing ? editingBackgroundColor : Color.clear)
        .cornerRadius(10)
        .shadow(color: isEditing ? Color.black.opacity(0.1) : Color.clear, radius: 4, x: 0, y: 2)
        .contentShape(Rectangle()) // Makes the whole row tappable
    }

    private func toggleCompletion() {
        item.isCompleted.toggle()
        try? modelContext.save()
    }

    private func saveChanges() {
        item.title = editedTitle
        try? modelContext.save()
        editingItemID = nil  // Reset editingItemID after committing changes
    }

    private func moveCursorToEnd() {
        // Temporarily add an invisible character to set the cursor at the end, then remove it
        editedTitle += "\u{200B}"  // Add zero-width space
        DispatchQueue.main.async {
            editedTitle = String(editedTitle.dropLast())  // Remove the zero-width space
        }
    }
}
