import Foundation
import SwiftData

@Model
final class Item {
    var id = UUID()
    var title: String
    var timestamp: Date
    var isCompleted: Bool
    var project: Project?  // Optional project association
    private var categoryRawValue: String = TaskCategory.inbox.rawValue
    
    var category: TaskCategory {
        get { TaskCategory(rawValue: categoryRawValue) ?? .inbox }
        set { categoryRawValue = newValue.rawValue }
    }

    init(title: String, timestamp: Date = Date(), isCompleted: Bool = false, category: TaskCategory = .inbox, project: Project? = nil) {
        self.title = title
        self.timestamp = timestamp
        self.isCompleted = isCompleted
        self.categoryRawValue = category.rawValue
        self.project = project
    }
}
