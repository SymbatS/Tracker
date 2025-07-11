import UIKit

struct Tracker {
    let id: UUID               // Уникальный идентификатор трекера
    let name: String           // Название трекера
    let color: UIColor         // Цвет, связанный с трекером
    let emoji: String          // Эмоджи для визуального представления
    let schedule: Set<WeekDay> // Расписание выполнения (если пустое — нерегулярный)
    let category: String
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
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
}

extension WeekDay {
    var shortTitle: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}
