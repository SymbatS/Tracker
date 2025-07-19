import UIKit

final class CategorySelectionViewController: UIViewController {
    
    private let trackerCategoryStore = TrackerCategoryStore()
    private var categories: [TrackerCategory] = []
    
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
        trackerCategoryStore.delegate = self
        navigationItem.hidesBackButton = true
        setupUI()
        reloadCategories()
    }
    
    private func reloadCategories() {
        categories = trackerCategoryStore.categories
        tableView.reloadData()
        updateEmptyStateVisibility()
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
    
    @objc private func addCategoryTapped() {
        let addVC = AddCategoryViewController()
        addVC.onCategoryCreated = { [weak self] newCategoryTitle in
            _ = self?.trackerCategoryStore.fetchOrCreateCategory(with: newCategoryTitle)
        }
        navigationController?.pushViewController(addVC, animated: true)
    }
}

extension CategorySelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = categories[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onCategorySelected?(categories[indexPath.row].title)
        navigationController?.popViewController(animated: true)
    }
}

extension CategorySelectionViewController: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        reloadCategories()
    }
}
