import UIKit

final class EditCategoryViewController: UIViewController {
    
    var category: TrackerCategory
    var onRename: ((String) -> Void)?
    
    private let viewModel = EditCategoryViewModel()
    private let keyboardHandler = KeyboardHandler()
    
    private let textField = UITextField()
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.backgroundColor = .lightGray
        return button
    }()
    
    init(category: TrackerCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Редактирование категории"
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        keyboardHandler.setup(for: self)
        textField.delegate = keyboardHandler
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        textField.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        textField.font = .systemFont(ofSize: 17)
        textField.text = category.title
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
            textField.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: guide.topAnchor, constant: 24),
            
            doneButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        viewModel.updateText(category.title)
    }
    
    private func bindViewModel() {
        viewModel.onValidationChanged = { [weak self] isValid in
            self?.doneButton.isEnabled = isValid
            self?.doneButton.backgroundColor = isValid ? .black : .lightGray
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.updateText(textField.text ?? "")
        let final = viewModel.getFinalText()
        if final != textField.text {
            textField.text = final
        }
    }
    
    @objc private func saveTapped() {
        let finalText = viewModel.getFinalText()
        guard !finalText.isEmpty else { return }
        onRename?(finalText)
        navigationController?.popViewController(animated: true)
    }
}
