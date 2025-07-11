import UIKit

struct CategoryStorage {
    private static let key = "tracker_categories"

    static var savedCategories: [String] {
        get {
            UserDefaults.standard.stringArray(forKey: key) ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    static func addCategory(_ category: String) {
        var categories = savedCategories
        if !categories.contains(category) {
            categories.append(category)
            savedCategories = categories
        }
    }
}
