import Foundation

enum TrackerType: String {
    case habit
    case event
}

struct TrackerFormConfiguration {
    let type: TrackerType
    let title: String
    let showSchedule: Bool
    let existingTracker: Tracker?
    let completedCount: Int?
    
    init(
        type: TrackerType,
        title: String,
        showSchedule: Bool,
        existingTracker: Tracker? = nil,
        completedCount: Int? = nil
    ) {
        self.type = type
        self.title = title
        self.showSchedule = showSchedule
        self.existingTracker = existingTracker
        self.completedCount = completedCount
    }
    
    init(tracker: Tracker, completedCount: Int? = nil) {
        self.type = tracker.type
        self.title = "Редактирование привычки"
        self.showSchedule = tracker.type == .habit
        self.existingTracker = tracker
        self.completedCount = completedCount
    }
}
