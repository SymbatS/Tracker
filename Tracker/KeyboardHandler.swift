import UIKit

final class KeyboardHandler: NSObject, UITextFieldDelegate {
    
    func setup(for viewController: UIViewController) {
        let tap = UITapGestureRecognizer(target: viewController.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        viewController.view.addGestureRecognizer(tap)
    }
    
    // MARK: - UITextFieldDelagate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
