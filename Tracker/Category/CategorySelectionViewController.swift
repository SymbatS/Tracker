import UIKit

final class CategorySelectionViewController: UIViewController {
    
    private let viewModel = CategorySelectionViewModel()
    private var categories: [TrackerCategory] = []
    var selectedCategoryTitle: String?
    var onCategorySelected: ((String) -> Void)?
    
    private let tableView = UITableView()
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        return button
    }()
    
    private let emptyStateView = UIView()
    private let image = UIImageView()
    private let smallTitle = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupUI()
        viewModel.onCategoriesUpdated = { [weak self] categories in
            self?.categories = categories
            self?.tableView.reloadData()
            self?.updateEmptyStateVisibility()
        }
        viewModel.loadCategories()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Категория"
        
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.frame = view.bounds
        
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        setupEmptyState()
    }
    
    private func setupEmptyState() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        smallTitle.translatesAutoresizingMaskIntoConstraints = false
        
        image.image = UIImage(named: "Star")
        smallTitle.text = "Привычки и события можно\nобъединить по смыслу"
        smallTitle.font = .systemFont(ofSize: 12)
        smallTitle.textColor = .black
        smallTitle.textAlignment = .center
        smallTitle.numberOfLines = 2
        
        emptyStateView.addSubview(image)
        emptyStateView.addSubview(smallTitle)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            image.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            image.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            smallTitle.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 8),
            smallTitle.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            smallTitle.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func updateEmptyStateVisibility() {
        let isEmpty = categories.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    private func presentEditScreen(for category: TrackerCategory) {
        let editVC = EditCategoryViewController(category: category)
        editVC.onRename = { [weak self] newTitle in
            self?.viewModel.renameCategory(id: category.id, newTitle: newTitle)
        }
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    private func confirmDeleteCategory(at indexPath: IndexPath) {
        let actionSheet = UIAlertController(
            title: "Эта категория точно не нужна?",
            message: nil,
            preferredStyle: .actionSheet
        )
        actionSheet.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self else { return }
            let category = self.categories[indexPath.row]
            self.viewModel.deleteCategory(id: category.id)
        })
        actionSheet.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        present(actionSheet, animated: true)
    }
    
    @objc private func addCategoryTapped() {
        let addVC = AddCategoryViewController()
        addVC.onCategoryCreated = { [weak self] newCategoryTitle in
            self?.viewModel.createCategory(title: newCategoryTitle)
        }
        navigationController?.pushViewController(addVC, animated: true)
    }
}

extension CategorySelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.title
        
        if category.title == selectedCategoryTitle {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategoryTitle = categories[indexPath.row].title
        onCategorySelected?(categories[indexPath.row].title)
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let category = categories[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }
            
            let edit = UIAction(title: "Редактировать") { _ in
                self.presentEditScreen(for: category)
            }
            
            let delete = UIAction(
                title: "Удалить",
                attributes: .destructive
            ) { _ in
                self.confirmDeleteCategory(at: indexPath)
            }
            
            return UIMenu(title: "", children: [edit, delete])
        }
    }
}
