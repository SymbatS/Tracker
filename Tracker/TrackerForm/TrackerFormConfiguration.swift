enum TrackerType: String {
    case habit
    case event
}

struct TrackerFormConfiguration {
    let type: TrackerType
    let title: String
    let showSchedule: Bool
}
