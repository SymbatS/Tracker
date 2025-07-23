import UIKit

final class TrackerFormViewController: UIViewController {
    
    weak var delegate: CreateTrackerDelegate?
    
    private let config: TrackerFormConfiguration
    
    private let nameTextField = UITextField()
    private let errorLabel = UILabel()
    private let scheduleLabel = UILabel()
    private let emojiLabel = UILabel()
    private let colorLabel = UILabel()
    private let emojiCollectionView = EmojiCollectionView()
    private let colorPickerCollectionView = ColorPickerCollectionView()
    private let cancelButton = UIButton()
    private let saveButton = UIButton()
    private let containerView = UIView()
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let keyboardHandler = KeyboardHandler()
    
    private var habitName = ""
    private var categoryTitle: String?
    private var categoryButton = UIButton()
    private var scheduleButton = UIButton()
    private var selectedSchedule: Set<WeekDay> = []
    private var selectedCategory: String?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    
    init(config: TrackerFormConfiguration) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16)
        ]
        title = config.title
        navigationItem.hidesBackButton = true
        keyboardHandler.setup(for: self)
        nameTextField.delegate = keyboardHandler
        emojiCollectionView.delegate = self
        colorPickerCollectionView.delegate = self
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        nameTextField.layer.cornerRadius = 16
        nameTextField.placeholder = "Введите название трекера"
        nameTextField.backgroundColor = UIColor(white: 0.9, alpha: 0.3)
        nameTextField.font = .systemFont(ofSize: 17)
        nameTextField.clearButtonMode = .whileEditing
        nameTextField.returnKeyType = .done
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        nameTextField.leftView = paddingView
        nameTextField.leftViewMode = .always
        
        errorLabel.textColor = .red
        errorLabel.font = .systemFont(ofSize: 17, weight: .regular)
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true
        
        containerView.layer.cornerRadius = 16
        containerView.backgroundColor = UIColor(white: 0.9, alpha: 0.3)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.heightAnchor.constraint(equalToConstant: config.showSchedule ? 150 : 75).isActive = true
        
        categoryButton = createArrowButton(title: "Категория", subtitle: nil)
        categoryButton.titleLabel?.font = .systemFont(ofSize: 17)
        categoryButton.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
        
        containerView.addSubview(categoryButton)
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categoryButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        if config.showSchedule {
            let separator = UIView()
            separator.backgroundColor = .gray
            separator.translatesAutoresizingMaskIntoConstraints = false
            
            scheduleButton = createArrowButton(title: "Расписание")
            scheduleButton.titleLabel?.font = .systemFont(ofSize: 17)
            scheduleButton.addTarget(self, action: #selector(scheduleTapped), for: .touchUpInside)
            
            containerView.addSubviews(separator, scheduleButton)
            separator.translatesAutoresizingMaskIntoConstraints = false
            scheduleButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                separator.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
                separator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                separator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                separator.heightAnchor.constraint(equalToConstant: 0.5),
                
                scheduleButton.topAnchor.constraint(equalTo: separator.bottomAnchor),
                scheduleButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                scheduleButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                scheduleButton.heightAnchor.constraint(equalToConstant: 75)
            ])
        }
        
        emojiLabel.text = "Emoji"
        emojiLabel.font = .systemFont(ofSize: 19, weight: .bold)
        colorLabel.text = "Цвет"
        colorLabel.font = .systemFont(ofSize: 19, weight: .bold)
        
        setupButtons()
        setupScrollView()
        layoutConstraints()
    }
    
    private func setupButtons() {
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.layer.borderColor = UIColor.red.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 16
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        saveButton.setTitle("Создать", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .gray
        saveButton.layer.cornerRadius = 16
        saveButton.isEnabled = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        scrollView.addSubview(contentStackView)
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -100),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    private func layoutConstraints() {
        
        let nameFieldContainer = UIView()
        nameFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameFieldContainer.addSubview(nameTextField)
        nameFieldContainer.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: nameFieldContainer.topAnchor),
            nameTextField.leadingAnchor.constraint(equalTo: nameFieldContainer.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: nameFieldContainer.trailingAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            errorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            errorLabel.centerXAnchor.constraint(equalTo: nameFieldContainer.centerXAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: nameFieldContainer.bottomAnchor)
        ])
        
        let emojiLabelWrapper = UIView()
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabelWrapper.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: emojiLabelWrapper.topAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: emojiLabelWrapper.leadingAnchor, constant: 12),
            emojiLabel.trailingAnchor.constraint(equalTo: emojiLabelWrapper.trailingAnchor),
            emojiLabel.bottomAnchor.constraint(equalTo: emojiLabelWrapper.bottomAnchor)
        ])
        
        let colorLabelWrapper = UIView()
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        colorLabelWrapper.addSubview(colorLabel)
        NSLayoutConstraint.activate([
            colorLabel.topAnchor.constraint(equalTo: colorLabelWrapper.topAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: colorLabelWrapper.leadingAnchor, constant: 12),
            colorLabel.trailingAnchor.constraint(equalTo: colorLabelWrapper.trailingAnchor),
            colorLabel.bottomAnchor.constraint(equalTo: colorLabelWrapper.bottomAnchor)
        ])
        
        [nameFieldContainer, containerView, emojiLabelWrapper, emojiCollectionView, colorLabelWrapper, colorPickerCollectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.addArrangedSubview($0)
        }
        
        nameTextField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        emojiCollectionView.heightAnchor.constraint(equalToConstant: 204).isActive = true
        colorPickerCollectionView.heightAnchor.constraint(equalToConstant: 204).isActive = true
        
        containerView.heightAnchor.constraint(equalToConstant: config.showSchedule ? 150 : 75).isActive = true
        contentStackView.setCustomSpacing(0, after: containerView)
        contentStackView.setCustomSpacing(0, after: emojiLabelWrapper)
        contentStackView.setCustomSpacing(0, after: emojiCollectionView)
        contentStackView.setCustomSpacing(0, after: colorLabelWrapper)
        view.addSubviews(cancelButton, saveButton)
        [cancelButton, saveButton].disableAutoResizingMasks()
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: colorPickerCollectionView.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            saveButton.topAnchor.constraint(equalTo: colorPickerCollectionView.bottomAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            
            cancelButton.widthAnchor.constraint(equalTo: saveButton.widthAnchor)
        ])
    }
    
    private func createArrowButton(title: String, subtitle: String? = nil) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.tag = 100
        
        let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrow.tintColor = .gray
        arrow.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(label)
        button.addSubview(arrow)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(greaterThanOrEqualTo: button.topAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(lessThanOrEqualTo: arrow.leadingAnchor, constant: -8),
            
            arrow.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            arrow.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16)
        ])
        
        let attributedText = NSMutableAttributedString(
            string: title + (subtitle != nil ? "\n" : ""),
            attributes: [
                .font: UIFont.systemFont(ofSize: 17),
                .foregroundColor: UIColor.black
            ]
        )
        
        if let subtitle = subtitle {
            attributedText.append(NSAttributedString(
                string: subtitle,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 17),
                    .foregroundColor: UIColor.gray
                ]
            ))
        }
        
        label.attributedText = attributedText
        
        return button
    }
    
    private func validateForm() {
        let isValid = !habitName.isEmpty &&
        selectedEmoji != nil &&
        selectedColor != nil &&
        selectedCategory != nil &&
        (config.showSchedule ? !selectedSchedule.isEmpty : true)
        
        saveButton.isEnabled = isValid
        saveButton.backgroundColor = isValid ? .black : .gray
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        habitName = textField.text ?? ""
        if habitName.count > 38 {
            textField.text = String(habitName.prefix(38))
            errorLabel.text = "Ограничение 38 символов"
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
        }
        validateForm()
    }
    
    @objc private func categoryTapped() {
        let vc = CategorySelectionViewController()
        vc.onCategorySelected = { [weak self] selectedCategory in
            guard let self = self else { return }
            self.selectedCategory = selectedCategory
            self.validateForm()
            if let label = self.categoryButton.subviews.compactMap({ $0 as? UILabel }).first {
                let title = NSAttributedString(
                    string: "Категория\n",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 17),
                        .foregroundColor: UIColor.black
                    ]
                )
                
                let subtitle = NSAttributedString(
                    string: selectedCategory,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 17),
                        .foregroundColor: UIColor.gray
                    ]
                )
                
                let fullText = NSMutableAttributedString()
                fullText.append(title)
                fullText.append(subtitle)
                label.attributedText = fullText
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func scheduleTapped() {
        let vc = ScheduleViewController()
        vc.onSave = { [weak self] selectedDays in
            guard let self = self else { return }
            self.selectedSchedule = selectedDays
            self.validateForm()
            let short: String
            if selectedDays.count == 7 {
                short = "Каждый день"
            } else {
                short = selectedDays
                    .sorted { $0.rawValue < $1.rawValue }
                    .map { $0.shortTitle }
                    .joined(separator: ", ")
            }
            
            let fullText = NSMutableAttributedString()
            
            let title = NSAttributedString(
                string: "Расписание\n",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 17),
                    .foregroundColor: UIColor.black
                ]
            )
            
            let subtitle = NSAttributedString(
                string: short,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 17),
                    .foregroundColor: UIColor.gray
                ]
            )
            
            fullText.append(title)
            fullText.append(subtitle)
            
            if let label = self.scheduleButton.subviews.compactMap({ $0 as? UILabel }).first {
                label.attributedText = fullText
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard let emoji = selectedEmoji, let color = selectedColor, let category = selectedCategory else { return }
        
        let tracker = Tracker(
            id: UUID(),
            name: habitName,
            color: color,
            emoji: emoji,
            schedule: config.showSchedule ? selectedSchedule : [],
            category: category,
            type: config.type
        )
        
        delegate?.didCreateTracker(tracker)
        delegate?.didFinishCreation()
        dismiss(animated: true)
    }
}

extension TrackerFormViewController: EmojiCollectionViewDelegate {
    func didSelectEmoji(_ emoji: String) {
        selectedEmoji = emoji
        validateForm()
    }
}

extension TrackerFormViewController: ColorPickerCollectionViewDelegate {
    func didSelectColor(_ color: UIColor) {
        selectedColor = color
        validateForm()
    }
}
