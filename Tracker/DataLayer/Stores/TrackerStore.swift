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
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
    }
}
