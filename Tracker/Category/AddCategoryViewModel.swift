import Foundation

final class AddCategoryViewModel {
    
    var onValidationChanged: ((Bool) -> Void)?
    
    private(set) var categoryName: String = "" {
        didSet {
            let trimmed = categoryName.trimmingCharacters(in: .whitespaces)
            let isValid = !trimmed.isEmpty && trimmed.count <= 38
            onValidationChanged?(isValid)
        }
    }
    
    func updateCategoryName(_ text: String) {
        categoryName = String(text.prefix(38))
    }
    
    func getTrimmedName() -> String {
        return categoryName.trimmingCharacters(in: .whitespaces)
    }
}
