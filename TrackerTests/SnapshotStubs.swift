import UIKit
import CoreData
@testable import Tracker

func makeSnapshotViewModel() -> TrackersViewModel {
    let stack = TestCoreDataStack(modelName: "TrackerDataModel")
    
    seedDemoData(into: stack.context)
    
    let categoryStore = TrackerCategoryStore(context: stack.context)
    let trackerStore  = TrackerStore(context: stack.context)
    let recordStore   = TrackerRecordStore(context: stack.context)
    
    let vm = TrackersViewModel(
        trackerStore: trackerStore,
        trackerCategoryStore: categoryStore,
        trackerRecordStore: recordStore
    )
    return vm
}

private func seedDemoData(into ctx: NSManagedObjectContext) {
    let c1 = TrackerCategoryCoreData(context: ctx)
    c1.id = UUID()
    c1.title = "Здоровье"
    
    let c2 = TrackerCategoryCoreData(context: ctx)
    c2.id = UUID()
    c2.title = "Важное"
    
    let everyday = WeekDay.allCases.map { NSNumber(value: $0.rawValue) } as NSArray
    
    let t1 = TrackerCoreData(context: ctx)
    t1.id = UUID()
    t1.name = "Покушать"
    t1.emoji = "🍔"
    t1.color = "#FD4C49"
    t1.schedule = everyday
    t1.isPinned = true
    t1.category = c1
    t1.type = TrackerType.habit.rawValue
    
    let t2 = TrackerCoreData(context: ctx)
    t2.id = UUID()
    t2.name = "Поиграть на гитаре 30 минут"
    t2.emoji = "🎸"
    t2.color = "#FF881E"
    t2.schedule = everyday
    t2.isPinned = false
    t2.category = c1
    t2.type = TrackerType.habit.rawValue
    
    let t3 = TrackerCoreData(context: ctx)
    t3.id = UUID()
    t3.name = "Покормить кота"
    t3.emoji = "😻"
    t3.color = "#007BFA"
    t3.schedule = everyday
    t3.isPinned = false
    t3.category = c2
    t3.type = TrackerType.habit.rawValue
    
    try? ctx.save()
}
