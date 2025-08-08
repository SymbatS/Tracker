import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: Set<WeekDay>
    let category: String
    let type: TrackerType
    let isPinned: Bool
}

enum WeekDay: Int, CaseIterable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

extension WeekDay {
    var displayName: String {
        switch self {
        case .monday: return NSLocalizedString("mondayDayTitle", comment: "Дни недели")
        case .tuesday: return NSLocalizedString("tuesdayDayTitle", comment: "Дни недели")
        case .wednesday: return NSLocalizedString("wednesdayDayTitle", comment: "Дни недели")
        case .thursday: return NSLocalizedString("thursdayDayTitle", comment: "Дни недели")
        case .friday: return NSLocalizedString("fridayDayTitle", comment: "Дни недели")
        case .saturday: return NSLocalizedString("saturdayDayTitle", comment: "Дни недели")
        case .sunday: return NSLocalizedString("sundayDayTitle", comment: "Дни недели")
        }
    }
}

extension WeekDay {
    var shortTitle: String {
        switch self {
        case .monday: return NSLocalizedString("mondayShortTitle", comment: "Краткое название дней недели")
        case .tuesday: return NSLocalizedString("tuesdayShortTitle", comment: "Краткое название дней недели")
        case .wednesday: return NSLocalizedString("wednesdayShortTitle", comment: "Краткое название дней недели")
        case .thursday: return NSLocalizedString("thursdayShortTitle", comment: "Краткое название дней недели")
        case .friday: return NSLocalizedString("fridayShortTitle", comment: "Краткое название дней недели")
        case .saturday: return NSLocalizedString("saturdayShortTitle", comment: "Краткое название дней недели")
        case .sunday: return NSLocalizedString("sundayShortTitle", comment: "Краткое название дней недели")
        }
    }
}
