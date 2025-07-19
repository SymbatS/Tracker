import UIKit

final class AddCategoryViewController: UIViewController {
    
    private let trackerCategoryStore = TrackerCategoryStore()
    var onCategoryCreated: ((String) -> Void)?
    
    private let textField = UITextField()
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.backgroundColor = .lightGray
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Новая категория"
        
        textField.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        textField.placeholder = "Введите название категории"
        textField.font = .systemFont(ofSize: 17)
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.layer.cornerRadius = 16
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        doneButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        view.addSubviews(textField, doneButton)
        [textField, doneButton].disableAutoResizingMasks()
        
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: guide.topAnchor, constant: 24),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func saveTapped() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty else { return }
        onCategoryCreated?(text)
        navigationController?.popViewController(animated: true)
    }
    
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let trimmed = textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let isValid = !trimmed.isEmpty
        doneButton.isEnabled = isValid
        doneButton.backgroundColor = isValid ? .black : .gray
        
        if trimmed.count > 38 {
            textField.text = String(trimmed.prefix(38))
        }
    }
}
