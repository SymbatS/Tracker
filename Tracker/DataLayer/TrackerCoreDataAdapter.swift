import CoreData
import UIKit

final class TrackerCoreDataAdapter {
    static func makeTracker(from object: TrackerCoreData) -> Tracker? {
        guard
            let id = object.id,
            let name = object.name,
            let emoji = object.emoji,
            let colorHex = object.color,
            let color = UIColor(hex: colorHex),
            let category = object.category,
            let categoryTitle = category.title,
            let typeRaw = object.type,
            let type = TrackerType(rawValue: typeRaw)
        else {
            return nil
        }
        
        let scheduleRaw = (object.schedule as? [NSNumber])?.compactMap { WeekDay(rawValue: $0.intValue) } ?? []
        let scheduleSet = Set(scheduleRaw)
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: scheduleSet,
            category: categoryTitle,
            type: type,
            isPinned: object.isPinned
        )
    }
    
    static func fill(_ object: TrackerCoreData, from tracker: Tracker, in context: NSManagedObjectContext) {
        object.id = tracker.id
        object.name = tracker.name
        object.emoji = tracker.emoji
        object.color = tracker.color.toHexString()
        object.type = tracker.type.rawValue
        object.schedule = tracker.schedule.map { NSNumber(value: $0.rawValue) } as NSArray
        object.isPinned = tracker.isPinned
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", tracker.category)
        
        let existingCategory = try? context.fetch(fetchRequest).first
        
        let categoryObject = existingCategory ?? {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = tracker.category
            return newCategory
        }()
        
        object.category = categoryObject
    }
}
