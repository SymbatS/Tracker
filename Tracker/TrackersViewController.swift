import UIKit

final class TrackersViewController: UIViewController {
    
    private let largeTitle = UILabel()
    private let plusButton = UIButton()
    private let datePicker = UIDatePicker()
    private let searchField = UITextField()
    private let image = UIImageView()
    private let smallTitle = UILabel()
    private let filterButton = UIButton()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
    private var collectionView: UICollectionView!
    private var trackers: [Tracker] = []
    private var categories: [TrackerCategory] = []
    var completedTrackers: Set<TrackerRecord> = []
    private var filteredCategories: [TrackerCategory] = []
    private var currentDate: Date = Calendar.current.startOfDay(for: Date())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
        filterTrackers(for: currentDate)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        let emptyStateView = UIView()
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(largeTitle, plusButton, datePicker, searchField, emptyStateView)
        [largeTitle, plusButton, datePicker, searchField, emptyStateView].disableAutoResizingMasks()
        
        emptyStateView.addSubviews(image, smallTitle)
        [image, smallTitle].disableAutoResizingMasks()
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.headerReferenceSize = CGSize(width: view.bounds.width, height: 18)
        
        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor, constant: -20),
            
            smallTitle.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 8),
            smallTitle.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor)
        ])
        
        plusButton.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
        plusButton.setImage(UIImage(named: "AddTracker"), for: .normal)
        
        largeTitle.text = "Трекеры"
        largeTitle.font = .systemFont(ofSize: 34, weight: .bold)
        largeTitle.textColor = .black
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
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
        
        image.image = UIImage(named: "Star")
        smallTitle.text = "Что будем отслеживать?"
        smallTitle.font = .systemFont(ofSize: 12)
        smallTitle.textColor = .black
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(TrackerSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        view.addSubview(collectionView)
        
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
            emptyStateView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 16),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
        
        filterButton.setTitle("Фильтры", for: .normal)
        filterButton.setTitleColor(.white, for: .normal)
        filterButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        filterButton.backgroundColor = .systemBlue
        filterButton.layer.cornerRadius = 16
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterButton)
        
        NSLayoutConstraint.activate([
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func updateEmptyState() {
        let hasVisibleTrackers = !filteredCategories.flatMap { $0.trackers }.isEmpty
        collectionView.isHidden = !hasVisibleTrackers
        image.isHidden = hasVisibleTrackers
        smallTitle.isHidden = hasVisibleTrackers
        filterButton.isHidden = !hasVisibleTrackers
    }
    
    private func filterTrackers(for date: Date) {
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
            return TrackerCategory(title: category.title, trackers: trackersForDay)
        }.filter { !$0.trackers.isEmpty }
        
        collectionView.reloadData()
        updateEmptyState()
    }
    
    @objc private func didTapPlusButton() {
        let createTrackerVC = CreateTrackerViewController()
        createTrackerVC.delegate = self
        let navVC = UINavigationController(rootViewController: createTrackerVC)
        present(navVC, animated: true)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = Calendar.current.startOfDay(for: sender.date)
        filterTrackers(for: currentDate)
    }
    
    @objc private func searchTextChanged() {
        filterTrackers(for: currentDate)
    }
    
}

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
            
            if self.completedTrackers.contains(record) {
                self.completedTrackers.remove(record)
            } else {
                self.completedTrackers.insert(record)
            }
            
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
}

extension TrackersViewController: CreateTrackerDelegate {
    func didCreateTracker(_ tracker: Tracker) {
        if let index = categories.firstIndex(where: { $0.title == tracker.category }) {
            let updatedCategory = categories[index]
            let updatedTrackers = updatedCategory.trackers + [tracker]
            let newCategory = TrackerCategory(title: updatedCategory.title, trackers: updatedTrackers)
            
            categories = categories.enumerated().map {
                $0.offset == index ? newCategory : $0.element
            }
        } else {
            categories.append(TrackerCategory(title: tracker.category, trackers: [tracker]))
        }
        collectionView.reloadData()
        updateEmptyState()
    }
    func didFinishCreation() {
        filterTrackers(for: currentDate)
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

