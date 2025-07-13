import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}

extension Array where Element: UIView {
    func disableAutoResizingMasks() {
        forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
}

extension UIStackView {
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach { self.addArrangedSubview($0) }
    }
}
