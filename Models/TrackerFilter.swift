enum TrackerFilter: Equatable {
    case all
    case today
    case completed
    case incomplete
    
    var showsCheckmark: Bool {
        switch self {
        case .completed, .incomplete: return true
        case .all, .today: return false
        }
    }
}
