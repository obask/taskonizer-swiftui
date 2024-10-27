import Foundation
import SwiftData

@Model
final class Project {
    var id = UUID()
    var name: String
    
    init(name: String) {
        self.name = name
    }
}
