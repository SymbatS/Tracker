import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrackers()
}

final class TrackerStore: NSObject {
    
    // MARK: - Properties
    
    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TrackerCoreData>
    weak var delegate: TrackerStoreDelegate?
    
    var trackers: [Tracker] {
        fetchedResultsController.fetchedObjects?.compactMap {
            TrackerCoreDataAdapter.makeTracker(from: $0)
        } ?? []
    }
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
        
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка при fetch в TrackerStore: \(error)")
        }
    }
    
    // MARK: - Public Methods
    
    func addTracker(_ tracker: Tracker, to category: TrackerCategoryCoreData) throws {
        let trackerEntity = TrackerCoreData(context: context)
        TrackerCoreDataAdapter.fill(trackerEntity, from: tracker, in: context)
        trackerEntity.category = category
        trackerEntity.isPinned = tracker.isPinned
        CoreDataStack.shared.saveContext()
        delegate?.didUpdateTrackers()
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        if let trackerToDelete = try context.fetch(request).first {
            context.delete(trackerToDelete)
            CoreDataStack.shared.saveContext()
        }
    }
    
    func fetchOrCreateCategory(with title: String) -> TrackerCategoryCoreData {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)

        if let existing = try? context.fetch(request).first {
            return existing
        }

        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.id = UUID()
        newCategory.title = title
        try? context.save()
        return newCategory
    }

    func togglePin(for tracker: Tracker) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        guard let trackerObject = try context.fetch(request).first else { return }

        trackerObject.isPinned.toggle()
        
        try context.save()
        delegate?.didUpdateTrackers()
    }
    
    func updateTracker(_ tracker: Tracker, to category: TrackerCategoryCoreData) throws {
        guard let object = try fetchTrackerCoreData(by: tracker.id) else { return }

        object.name = tracker.name
        object.emoji = tracker.emoji
        object.color = tracker.color.toHexString()
        object.schedule = tracker.schedule.map { NSNumber(value: $0.rawValue) } as NSArray
        object.category = category
        object.isPinned = tracker.isPinned

        try context.save()
    }
    
    private func fetchTrackerCoreData(by id: UUID) throws -> TrackerCoreData? {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
    }
}
