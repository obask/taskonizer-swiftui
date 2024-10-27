import SwiftUI
import SwiftData
import AppKit

struct TaskRow: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: Item
    @Binding var isExpanded: Bool  // Track if the task is expanded
    @Binding var editedTitle: String
    @Binding var editingItemID: UUID?  // Binding to reset editingItemID after commit
    @Namespace private var animationNamespace  // Namespace for matched geometry effect
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
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Button(action: toggleCompletion) {
                    Image(systemName: item.isCompleted ? "checkmark.square" : "square")
                        .foregroundColor(item.isCompleted ? .green : .gray)
                        .imageScale(.large)
                }

                VStack(alignment: .leading) {
                    if isExpanded {
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
                            .matchedGeometryEffect(id: "title\(item.id)", in: animationNamespace)
                    } else {
                        Text(item.title)
                            .strikethrough(item.isCompleted)
                            .padding(.vertical, 4)
                            .font(.body)
                            .matchedGeometryEffect(id: "title\(item.id)", in: animationNamespace)
                    }
                }
                .padding(.leading, 5)

                Spacer()

                if isExpanded {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.blue)
                        .matchedGeometryEffect(id: "editIcon\(item.id)", in: animationNamespace)
                }
            }

            if isExpanded {
                Text("Additional Details")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .transition(.opacity)
                    .matchedGeometryEffect(id: "details\(item.id)", in: animationNamespace)
            }
        }
        .padding(8)
        .background(isExpanded ? editingBackgroundColor : Color.clear)  // Use custom background only in expanded mode
        .cornerRadius(10)
        .shadow(color: isExpanded ? Color.black.opacity(0.1) : Color.clear, radius: 4, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }
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
