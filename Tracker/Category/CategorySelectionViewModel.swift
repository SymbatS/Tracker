import Foundation

final class CategorySelectionViewModel {
    
    // MARK: - Properties
    private let categoryStore: TrackerCategoryStore
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesUpdated?(categories)
        }
    }
    
    var onCategoriesUpdated: (([TrackerCategory]) -> Void)?
    
    init(categoryStore: TrackerCategoryStore = TrackerCategoryStore()) {
        self.categoryStore = categoryStore
        self.categoryStore.delegate = self
        loadCategories()
    }
    
    func loadCategories() {
        categories = categoryStore.categories
    }
    
    func createCategory(title: String) {
        _ = categoryStore.fetchOrCreateCategory(with: title)
    }
    
    func renameCategory(id: UUID, newTitle: String) {
        categoryStore.renameCategory(withId: id, to: newTitle)
    }
    
    func deleteCategory(id: UUID) {
        categoryStore.deleteCategory(withId: id)
    }
}

extension CategorySelectionViewModel: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        loadCategories()
    }
}
