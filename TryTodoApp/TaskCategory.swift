enum TaskCategory: String, CaseIterable {
    case inbox = "Inbox"
    case today = "Today"
    case upcoming = "Upcoming"
    case anytime = "Anytime"
    case someday = "Someday"
    case logbook = "Logbook"
    case trash = "Trash"
    
    var iconName: String {
        switch self {
        case .inbox: return "tray"
        case .today: return "star"
        case .upcoming: return "calendar"
        case .anytime: return "clock"
        case .someday: return "archivebox"
        case .logbook: return "book"
        case .trash: return "trash"
        }
    }
}
