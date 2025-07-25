import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategories()
}

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    var categories: [TrackerCategory] {
        fetchedResultsController.fetchedObjects?.compactMap { category in
            guard
                let id = category.id,
                let title = category.title,
                let trackersNSSet = category.trackers as? Set<TrackerCoreData>
            else {
                return nil
            }
            
            let trackers = trackersNSSet.compactMap {
                TrackerCoreDataAdapter.makeTracker(from: $0)
            }
            
            return TrackerCategory(id: id, title: title, trackers: trackers)
        } ?? []
    }
    // MARK: - Init
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
        
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка при загрузке категорий: \(error)")
        }
    }
    // MARK: - Actions
    
    func fetchOrCreateCategory(with title: String) -> TrackerCategoryCoreData {
        let request = Self.categoryFetchRequest(title: title)
        if let existing = try? context.fetch(request).first {
            return existing
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.id = UUID()
            newCategory.title = title
            CoreDataStack.shared.saveContext()
            return newCategory
        }
    }
    
    func renameCategory(withId id: UUID, to newTitle: String) {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if let category = try? context.fetch(request).first {
            category.title = newTitle
            CoreDataStack.shared.saveContext()
            delegate?.didUpdateCategories()
        }
    }

    func deleteCategory(withId id: UUID) {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if let category = try? context.fetch(request).first {
            context.delete(category)
            CoreDataStack.shared.saveContext()
            delegate?.didUpdateCategories()
        }
    }
    
    private static func categoryFetchRequest(title: String) -> NSFetchRequest<TrackerCategoryCoreData> {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        return request
    }
}
// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories()
    }
}
