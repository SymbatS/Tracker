import UIKit

final class KeyboardHandler: NSObject, UITextFieldDelegate {
    
    weak var delegate: KeyboardHandlerDelegate?
    
    func setup(for viewController: UIViewController) {
        let tap = UITapGestureRecognizer(target: viewController.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        viewController.view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillHide() {
        delegate?.didEndEditing()
    }
    
    // MARK: - UITextFieldDelagate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
