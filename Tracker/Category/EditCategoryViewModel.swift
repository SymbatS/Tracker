import Foundation

final class EditCategoryViewModel {
    var onValidationChanged: ((Bool) -> Void)?
    
    private(set) var currentText: String = ""
    
    func updateText(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        if trimmed.count > 38 {
            currentText = String(trimmed.prefix(38))
        } else {
            currentText = trimmed
        }
        onValidationChanged?(!currentText.isEmpty)
    }
    
    func getFinalText() -> String {
        return currentText
    }
}
