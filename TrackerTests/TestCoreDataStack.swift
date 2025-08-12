import CoreData
@testable import Tracker

final class TestCoreDataStack {
    let container: NSPersistentContainer
    var context: NSManagedObjectContext { container.viewContext }
    
    init(modelName: String = "TrackerDataModel") {
        let appBundle = Bundle(for: CoreDataStack.self)
        
        guard let url = appBundle.url(forResource: modelName, withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Не нашёл модель \(modelName).momd в бандле \(appBundle.bundleURL.lastPathComponent)")
        }
        
        container = NSPersistentContainer(name: "TestContainer", managedObjectModel: model)
        
        let desc = NSPersistentStoreDescription()
        desc.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [desc]
        
        var loadError: Error?
        container.loadPersistentStores { _, error in loadError = error }
        assert(loadError == nil, "Не удалось загрузить In-Memory store: \(String(describing: loadError))")
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
