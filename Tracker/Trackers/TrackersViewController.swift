import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let keyboardHandler = KeyboardHandler()
    private var trackers: [Tracker] = []
    private var categories: [TrackerCategory] = []
    var completedTrackers: Set<TrackerRecord> = []
    private var filteredCategories: [TrackerCategory] = []
    private var currentDate: Date = Calendar.current.startOfDay(for: Date())
    
    // MARK: - UI Elements
    private let largeTitle = UILabel()
    private let plusButton = UIButton()
    private let datePicker = UIDatePicker()
    private let searchField = UITextField()
    private let image = UIImageView()
    private let smallTitle = UILabel()
    private let filterButton = UIButton()
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
        searchField.delegate = keyboardHandler
        trackerStore.delegate = self
        trackerRecordStore.delegate = self
        loadInitialData()
        updateFilteredCategories(for: currentDate)
    }
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubviews(largeTitle, plusButton, datePicker, searchField, collectionView, image, smallTitle, filterButton)
        [largeTitle, plusButton, datePicker, searchField, collectionView, image, smallTitle, filterButton].disableAutoResizingMasks()
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
        plusButton.setImage(UIImage(named: "AddTracker"), for: .normal)
        plusButton.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
    }
    
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    private func setupSearchField() {
        searchField.placeholder = "Поиск"
        searchField.layer.cornerRadius = 10
        searchField.layer.masksToBounds = true
        searchField.backgroundColor = UIColor(red: 118/255, green: 118/255, blue: 128/255, alpha: 0.12)
        
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = .gray
        imageView.frame = CGRect(x: 8, y: 2, width: 15, height: 15)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        paddingView.addSubview(imageView)
        
        searchField.leftView = paddingView
        searchField.leftViewMode = .always
        searchField.clearButtonMode = .whileEditing
        searchField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
    }
    
    private func setupEmptyState() {
        image.image = UIImage(named: "Star")
        smallTitle.text = "Что будем отслеживать?"
        smallTitle.font = .systemFont(ofSize: 12)
        smallTitle.textColor = .black
    }
    
    private func setupFilterButton() {
        filterButton.setTitle("Фильтры", for: .normal)
        filterButton.setTitleColor(.white, for: .normal)
        filterButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        filterButton.backgroundColor = .systemBlue
        filterButton.layer.cornerRadius = 16
        filterButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func updateEmptyState() {
        let hasVisibleTrackers = !filteredCategories.flatMap { $0.trackers }.isEmpty
        collectionView.isHidden = !hasVisibleTrackers
        image.isHidden = hasVisibleTrackers
        smallTitle.isHidden = hasVisibleTrackers
        filterButton.isHidden = !hasVisibleTrackers
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
            
            searchField.topAnchor.constraint(equalTo: largeTitle.bottomAnchor, constant: 7),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 36),
            
            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            
            smallTitle.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 8),
            smallTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Data
    private func loadInitialData() {
        categories = trackerCategoryStore.categories
        completedTrackers = trackerRecordStore.records
        updateFilteredCategories(for: currentDate)
    }
    
    private func updateFilteredCategories(for date: Date) {
        let calendar = Calendar.current
        let selectedWeekday = calendar.component(.weekday, from: date)
        let weekday = WeekDay(rawValue: (selectedWeekday + 5) % 7 + 1) ?? .monday
        let searchText = searchField.text?.lowercased() ?? ""
        
        filteredCategories = categories.map { category in
            let trackersForDay = category.trackers.filter { tracker in
                let isIrregularEvent = tracker.schedule.isEmpty
                let isScheduledForToday = tracker.schedule.contains(weekday)
                let matchesSearch = searchText.isEmpty || tracker.name.lowercased().contains(searchText)
                
                let wasTracked = completedTrackers.contains { record in
                    record.id == tracker.id
                }
                
                let wasTrackedToday = completedTrackers.contains { record in
                    record.id == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: date)
                }
                
                let shouldShow: Bool
                
                if isIrregularEvent {
                    shouldShow = !wasTracked || wasTrackedToday
                } else {
                    shouldShow = isScheduledForToday
                }
                
                return shouldShow && matchesSearch
            }
            return TrackerCategory(id: category.id, title: category.title, trackers: trackersForDay)
        }.filter { !$0.trackers.isEmpty }
        
        collectionView.reloadData()
        updateEmptyState()
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
        let isDone = completedTrackers.contains(record)
        let count = completedTrackers.filter { $0.id == trackerId }.count
        let isFuture = selectedDate > today
        
        cell.configure(with: tracker, isDone: isDone, count: count, isFuture: isFuture)
        
        cell.onToggleDone = { [weak self] in
            guard let self = self else { return }
            self.trackerRecordStore.toggleRecord(for: trackerId, date: selectedDate)
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
                try self.trackerStore.deleteTracker(tracker)
                self.categories = self.trackerCategoryStore.categories
                self.updateFilteredCategories(for: self.currentDate)
                completion(true)
            } catch {
                print("Ошибка при удалении трекера: \(error)")
                completion(false)
            }
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

final class TrackerSectionHeader: UICollectionReusableView {
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - Delegates

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        categories = trackerCategoryStore.categories
        updateFilteredCategories(for: currentDate)
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func didUpdateTrackers() {
        trackers = trackerStore.trackers
        updateFilteredCategories(for: currentDate)
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {
    func didUpdateRecords() {
        completedTrackers = trackerRecordStore.records
        updateFilteredCategories(for: currentDate)
    }
}

extension TrackersViewController: CreateTrackerDelegate {
    func didCreateTracker(_ tracker: Tracker) {
        let categoryCoreData = trackerCategoryStore.fetchOrCreateCategory(with: tracker.category)
        
        do {
            try trackerStore.addTracker(tracker, to: categoryCoreData)
            loadInitialData()
        } catch {
            print("Ошибка при сохранении трекера: \(error)")
        }
    }
    
    func didFinishCreation() {
        updateFilteredCategories(for: currentDate)
    }
}
