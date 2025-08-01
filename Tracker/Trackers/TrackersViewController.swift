import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: TrackersViewModel
    private let keyboardHandler = KeyboardHandler()
    private var filteredCategories: [TrackerCategory] = []
    private var currentDate: Date = Calendar.current.startOfDay(for: Date())
    private var isSearching: Bool {
        !(searchField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }
    
    // MARK: - Init
    
    init(viewModel: TrackersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    private let largeTitle = UILabel()
    private let plusButton = UIButton()
    private let datePicker = UIDatePicker()
    private let searchStack = UIStackView()
    private let searchField = UISearchTextField()
    private let imageStar = UIImageView()
    private let emptyStateLabel = UILabel()
    private let filterButton = UIButton()
    private let imageFinder = UIImageView()
    private let textFinder = UILabel()
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.isHidden = true
        return button
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.headerReferenceSize = CGSize(width: view.bounds.width, height: 18)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(TrackerSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        return collectionView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
        keyboardHandler.setup(for: self)
        keyboardHandler.delegate = self
        bindViewModel()
        updateFilteredCategories(for: currentDate)
    }
    // MARK: - Data binding
    
    private func bindViewModel() {
        viewModel.onCategoriesUpdated = { [weak self] _ in
            self?.updateFilteredCategories(for: self?.currentDate ?? Date())
        }

        viewModel.onCompletedTrackersUpdated = { [weak self] _ in
            self?.updateFilteredCategories(for: self?.currentDate ?? Date())
        }
    }

    private func updateFilteredCategories(for date: Date) {
        filteredCategories = viewModel.updateData(for: date, filter: searchField.text)
        collectionView.reloadData()
        updateEmptyState()
    }

    private func calculateWeekday(from date: Date) -> WeekDay {
        let calendar = Calendar.current
        let selectedWeekday = calendar.component(.weekday, from: date)
        return WeekDay(rawValue: (selectedWeekday + 5) % 7 + 1) ?? .monday
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubviews(largeTitle, plusButton, datePicker, searchStack, collectionView, imageStar, emptyStateLabel, imageFinder, textFinder, filterButton)
        [largeTitle, plusButton, datePicker, searchStack, cancelButton, collectionView, imageStar, emptyStateLabel, imageFinder, textFinder, filterButton].disableAutoResizingMasks()
        setupEmptyFinder()
        setupEmptyState()
        setupLargeTitle()
        setupPlusButton()
        setupDatePicker()
        setupSearchField()
        setupFilterButton()
        setupLayoutConstraints()
    }
    
    private func setupLargeTitle() {
        largeTitle.text = "Трекеры"
        largeTitle.font = .systemFont(ofSize: 34, weight: .bold)
        largeTitle.textColor = .black
    }
    
    private func setupPlusButton() {
        plusButton.setImage(UIImage(resource: .addTracker), for: .normal)
        plusButton.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
    }
    
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    private func setupSearchField() {
        searchStack.axis = .horizontal
        searchStack.spacing = 5
        searchStack.alignment = .fill
        searchStack.distribution = .fill
        
        searchStack.addArrangedSubview(searchField)
        searchStack.addArrangedSubview(cancelButton)
        
        cancelButton.isHidden = true
        cancelButton.setContentHuggingPriority(.required, for: .horizontal)
        
        searchField.placeholder = "Поиск"
        searchField.layer.cornerRadius = 10
        searchField.layer.masksToBounds = true
        searchField.backgroundColor = UIColor(red: 118/255, green: 118/255, blue: 128/255, alpha: 0.12)
        
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = .gray
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        paddingView.addSubview(imageView)
        
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        searchField.delegate = self
        searchField.leftView = paddingView
        searchField.leftViewMode = .always
        searchField.clearButtonMode = .whileEditing
        searchField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
    }
    
    private func setupEmptyState() {
        imageStar.image = UIImage(resource: .star)
        emptyStateLabel.text = "Что будем отслеживать?"
        emptyStateLabel.font = .systemFont(ofSize: 12)
        emptyStateLabel.textColor = .black
    }
    
    private func setupEmptyFinder() {
        imageFinder.image = UIImage(resource: .filterEmoji)
        textFinder.text = "Ничего не найдено"
        textFinder.font = .systemFont(ofSize: 12)
        textFinder.textColor = .black
        textFinder.textAlignment = .center
        
        imageFinder.isHidden = true
        textFinder.isHidden = true
    }
    
    private func showCancelButton(_ show: Bool) {
        cancelButton.isHidden = !show
    }
    
    private func setupFilterButton() {
        filterButton.setTitle("Фильтры", for: .normal)
        filterButton.setTitleColor(.white, for: .normal)
        filterButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        filterButton.backgroundColor = .systemBlue
        filterButton.layer.cornerRadius = 16
    }
    
    private func updateEmptyState() {
        let hasVisibleTrackers = !filteredCategories.flatMap { $0.trackers }.isEmpty
        
        collectionView.isHidden = !hasVisibleTrackers
        filterButton.isHidden = !hasVisibleTrackers
        
        if isSearching {
            imageFinder.isHidden = hasVisibleTrackers
            textFinder.isHidden = hasVisibleTrackers
            imageStar.isHidden = true
            emptyStateLabel.isHidden = true
        } else {
            imageStar.isHidden = hasVisibleTrackers
            emptyStateLabel.isHidden = hasVisibleTrackers
            imageFinder.isHidden = true
            textFinder.isHidden = true
        }
    }
    
    private func presentEditTrackerVC(_ tracker: Tracker) {
        let completedDays = viewModel.completedTrackers.filter { $0.id == tracker.id }.count
        let editVC = EditTrackerViewController(tracker: tracker, completedDays: completedDays)
        editVC.delegate = self
        let nav = UINavigationController(rootViewController: editVC)
        present(nav, animated: true)
    }
    
    private func confirmDeleteTracker(_ tracker: Tracker) {
        let alert = UIAlertController(title: "Уверены что хотите удалить трекер?",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            do {
                try self?.viewModel.deleteTracker(tracker)
            } catch {
                print("Ошибка удаления трекера: \(error)")
            }
        })
        
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        present(alert, animated: true)
    }

    
    private func setupLayoutConstraints() {
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: guide.topAnchor, constant: 1),
            plusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            plusButton.widthAnchor.constraint(equalToConstant: 42),
            plusButton.heightAnchor.constraint(equalToConstant: 42),
            
            datePicker.topAnchor.constraint(equalTo: guide.topAnchor, constant: 5),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            largeTitle.topAnchor.constraint(equalTo: guide.topAnchor, constant: 44),
            largeTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchStack.topAnchor.constraint(equalTo: largeTitle.bottomAnchor, constant: 7),
            searchStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchStack.heightAnchor.constraint(equalToConstant: 36),
            
            collectionView.topAnchor.constraint(equalTo: searchStack.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            
            imageStar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageStar.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            
            emptyStateLabel.topAnchor.constraint(equalTo: imageStar.bottomAnchor, constant: 8),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageFinder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageFinder.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            textFinder.topAnchor.constraint(equalTo: imageFinder.bottomAnchor, constant: 8),
            textFinder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Actions
    
    @objc private func didTapPlusButton() {
        let createTrackerVC = CreateTrackerViewController()
        createTrackerVC.delegate = self
        let navVC = UINavigationController(rootViewController: createTrackerVC)
        present(navVC, animated: true)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = Calendar.current.startOfDay(for: sender.date)
        updateFilteredCategories(for: currentDate)
    }
    
    @objc private func searchTextChanged() {
        updateFilteredCategories(for: currentDate)
    }
    
    @objc private func didTapCancel() {
        searchField.text = ""
        searchField.resignFirstResponder()
        showCancelButton(false)
        updateFilteredCategories(for: currentDate)
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        let trackerId = tracker.id
        let selectedDate = currentDate
        let today = Calendar.current.startOfDay(for: Date())
        
        let record = TrackerRecord(id: trackerId, date: selectedDate)
        let isDone = viewModel.completedTrackers.contains(record)
        let count = viewModel.completedTrackers.filter { $0.id == trackerId }.count
        let isFuture = selectedDate > today
        
        cell.configure(with: tracker, isDone: isDone, count: count, isFuture: isFuture)
        
        cell.onToggleDone = { [weak self] in
            guard let self = self else { return }
            viewModel.toggleDone(for: trackerId, date: selectedDate)
            self.collectionView.reloadItems(at: [indexPath])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsInRow: CGFloat = 2
        let interItemSpacing: CGFloat = 9
        let sectionInsets: CGFloat = 16 * 2
        
        let totalSpacing = (numberOfItemsInRow - 1) * interItemSpacing + sectionInsets
        let itemWidth = floor((collectionView.bounds.width - totalSpacing) / numberOfItemsInRow)
        
        return CGSize(width: itemWidth, height: 90 + 4 + 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as? TrackerSectionHeader else {
            return UICollectionReusableView()
        }
        header.titleLabel.text = filteredCategories[indexPath.section].title
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        trailingSwipeActionsConfigurationForItemAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            guard let self = self else { return }
            let tracker = self.filteredCategories[indexPath.section].trackers[indexPath.item]
            do {
                try self.viewModel.deleteTracker(tracker)
                self.updateFilteredCategories(for: self.currentDate)
                completion(true)
            } catch {
                print("Ошибка при удалении трекера: \(error)")
                completion(false)
            }
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else {
                return UIMenu(title: "", children: [])
            }
            
            let isPinned = tracker.isPinned
            let pinTitle = isPinned ? "Открепить" : "Закрепить"
            
            let pinAction = UIAction(title: pinTitle) { _ in
                do {
                    try self.viewModel.togglePin(for: tracker)
                    self.updateFilteredCategories(for: self.currentDate)
                } catch {
                    print("Ошибка при закреплении: \(error)")
                }
            }
            
            let editAction = UIAction(title: "Редактировать") { _ in
                self.presentEditTrackerVC(tracker)
            }
            
            let deleteAction = UIAction(
                title: "Удалить",
                attributes: .destructive
            ) { _ in
                self.confirmDeleteTracker(tracker)
            }
            
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
}

// MARK: - Delegates

extension TrackersViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        showCancelButton(true)
    }
}

extension TrackersViewController: KeyboardHandlerDelegate {
    func didEndEditing() {
        showCancelButton(false)
    }
}

extension TrackersViewController: CreateTrackerDelegate {
    func didUpdateTracker(_ tracker: Tracker) {
        try? viewModel.updateTracker(tracker)
    }
    
    func didCreateTracker(_ tracker: Tracker) {
        try? viewModel.addTracker(tracker)
    }
    
    func didFinishCreation() {
        updateFilteredCategories(for: currentDate)
    }
}
