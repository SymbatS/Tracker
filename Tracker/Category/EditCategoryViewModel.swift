import Foundation

final class EditCategoryViewModel {
    var onValidationChanged: ((Bool) -> Void)?
    
    private(set) var currentText: String = ""
    
    func updateText(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        currentText = trimmed.count > 38 ? String(trimmed.prefix(38)) : trimmed
        onValidationChanged?(!currentText.isEmpty)
    }
    
    func getFinalText() -> String {
        return currentText
    }
}
