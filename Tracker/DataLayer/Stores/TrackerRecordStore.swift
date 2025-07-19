import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdateRecords()
}

final class TrackerRecordStore: NSObject {
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    var records: Set<TrackerRecord> {
        Set(fetchedResultsController.fetchedObjects?.compactMap {
            guard let id = $0.id, let date = $0.date else { return nil }
            return TrackerRecord(id: id, date: date)
        } ?? [])
    }
    
    // MARK: - Init
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
        
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
    }
    
    // MARK: - Actions
    
    func addRecord(_ record: TrackerRecord) {
        let entity = TrackerRecordCoreData(context: context)
        entity.id = record.id
        entity.date = record.date
        CoreDataStack.shared.saveContext()
    }
    
    func deleteRecord(for trackerID: UUID, date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "id == %@ AND date >= %@ AND date < %@",
            trackerID as CVarArg,
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        if let existing = try? context.fetch(request).first {
            context.delete(existing)
            CoreDataStack.shared.saveContext()
        }
    }
    
    func toggleRecord(for trackerID: UUID, date: Date) {
        let record = TrackerRecord(id: trackerID, date: date)
        if records.contains(record) {
            deleteRecord(for: trackerID, date: date)
        } else {
            addRecord(record)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateRecords()
    }
}
