import Foundation
import SwiftData

@Model
final class Item {
    var id = UUID()
    var title: String
    var timestamp: Date
    var isCompleted: Bool
    private var categoryRawValue: String = TaskCategory.inbox.rawValue  // Set a default value
    
    var category: TaskCategory {
        get { TaskCategory(rawValue: categoryRawValue) ?? .inbox }
        set { categoryRawValue = newValue.rawValue }
    }

    init(title: String, timestamp: Date = Date(), isCompleted: Bool = false, category: TaskCategory = .inbox) {
        self.title = title
        self.timestamp = timestamp
        self.isCompleted = isCompleted
        self.categoryRawValue = category.rawValue
    }
}
