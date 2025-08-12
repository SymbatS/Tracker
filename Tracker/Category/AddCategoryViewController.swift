import UIKit

final class AddCategoryViewController: UIViewController {
    
    var onCategoryCreated: ((String) -> Void)?
    
    private let viewModel: AddCategoryViewModel
    private let keyboardHandler = KeyboardHandler()
    
    private let textField = UITextField()
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("doneButtonTitle", comment: "Кнопка готово"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.backgroundColor = .lightGray
        return button
    }()
    
    // MARK: - Init
    
    init(viewModel: AddCategoryViewModel = AddCategoryViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardHandler.setup(for: self)
        
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = NSLocalizedString("addCatetegoryTitle", comment: "Новая категория")
        navigationItem.hidesBackButton = true
        
        textField.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        textField.placeholder = NSLocalizedString("textFieldPlaceholder", comment: "Введите название категории")
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
    
    private func bindViewModel() {
        viewModel.onValidationChanged = { [weak self] isValid in
            self?.doneButton.isEnabled = isValid
            self?.doneButton.backgroundColor = isValid ? .black : .lightGray
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.updateCategoryName(textField.text ?? "")
    }
    
    @objc private func saveTapped() {
        let finalText = viewModel.getTrimmedName()
        guard !finalText.isEmpty else { return }
        onCategoryCreated?(finalText)
        navigationController?.popViewController(animated: true)
    }
}
