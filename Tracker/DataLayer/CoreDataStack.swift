import CoreData

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "TrackerDataModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error as NSError? {
                assertionFailure("Ошибка инициализации Core Data: \(error), \(error.userInfo)")
                return
            }
        }
    }
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Ошибка при сохранении: \(error)")
            }
        }
    }
}
