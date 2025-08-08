import Foundation

final class TrackersViewModel {

    // MARK: - Properties
    var onCategoriesUpdated: (([TrackerCategory]) -> Void)?
    var onCompletedTrackersUpdated: ((Set<TrackerRecord>) -> Void)?

    private(set) var categories: [TrackerCategory] = [] {
        didSet { onCategoriesUpdated?(categories) }
    }

    private(set) var completedTrackers: Set<TrackerRecord> = [] {
        didSet { onCompletedTrackersUpdated?(completedTrackers) }
    }

    private let trackerStore: TrackerStore
    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore

    init(
        trackerStore: TrackerStore,
        trackerCategoryStore: TrackerCategoryStore,
        trackerRecordStore: TrackerRecordStore
    ) {
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore
        self.trackerStore.delegate = self
        self.trackerCategoryStore.delegate = self
        self.trackerRecordStore.delegate = self

        categories = trackerCategoryStore.categories
        completedTrackers = trackerRecordStore.records
    }

    func updateData(for date: Date, filter: String?) -> [TrackerCategory] {
        let weekday = calculateWeekday(from: date)
        let searchText = (filter ?? "").lowercased()

        let pinnedTrackers = categories
            .flatMap { $0.trackers }
            .filter {
                $0.isPinned &&
                ($0.schedule.isEmpty || $0.schedule.contains(weekday)) &&
                (searchText.isEmpty || $0.name.lowercased().contains(searchText))
            }

        let regularCategories = categories
            .map { category -> TrackerCategory in
                let filteredTrackers = category.trackers.filter {
                    !$0.isPinned &&
                    ($0.schedule.isEmpty || $0.schedule.contains(weekday)) &&
                    (searchText.isEmpty || $0.name.lowercased().contains(searchText))
                }
                return TrackerCategory(id: category.id, title: category.title, trackers: filteredTrackers)
            }
            .filter { !$0.trackers.isEmpty }

        var result: [TrackerCategory] = []
        if !pinnedTrackers.isEmpty {
            result.append(TrackerCategory(id: UUID(), title: NSLocalizedString("pinnedTitle", comment: "Закреплённые"), trackers: pinnedTrackers))
        }
        result.append(contentsOf: regularCategories)
        return result
    }

    func toggleDone(for id: UUID, date: Date) {
        trackerRecordStore.toggleRecord(for: id, date: date)
    }

    func calculateWeekday(from date: Date) -> WeekDay {
        let calendar = Calendar.current
        let selectedWeekday = calendar.component(.weekday, from: date)
        return WeekDay(rawValue: (selectedWeekday + 5) % 7 + 1) ?? .monday
    }

    func deleteTracker(_ tracker: Tracker) throws {
        try trackerStore.deleteTracker(tracker)
    }

    func togglePin(for tracker: Tracker) throws {
        try trackerStore.togglePin(for: tracker)
    }

    func addTracker(_ tracker: Tracker) throws {
        let category = trackerCategoryStore.fetchOrCreateCategory(with: tracker.category)
        try trackerStore.addTracker(tracker, to: category)
    }

    func updateTracker(_ tracker: Tracker) throws {
        let category = trackerCategoryStore.fetchOrCreateCategory(with: tracker.category)
        try trackerStore.updateTracker(tracker, to: category)
    }
}

// MARK: - Delegates

extension TrackersViewModel: TrackerStoreDelegate {
    func didUpdateTrackers() {
        categories = trackerCategoryStore.categories
    }
}

extension TrackersViewModel: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        categories = trackerCategoryStore.categories
    }
}

extension TrackersViewModel: TrackerRecordStoreDelegate {
    func didUpdateRecords() {
        completedTrackers = trackerRecordStore.records
    }
}
