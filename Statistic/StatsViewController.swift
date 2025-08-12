import UIKit

private struct StatItem {
    let title: String
    let value: String
    let color: UIColor
}

private struct StatsSummary {
    let bestPeriodDays: Int
    let perfectDays: Int
    let totalCompleted: Int
    let averagePerDay: Double
}

final class StatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let viewModel: TrackersViewModel
    
    init(viewModel: TrackersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private let blue  = UIColor(hex: "#007BFA") ?? .systemBlue
    private let green = UIColor(hex: "#46E69D") ?? .systemGreen
    private let red   = UIColor(hex: "#FD4C49") ?? .systemRed
    private let largeTitle = UILabel()
    private let emptyStateView = UIView()
    private let image = UIImageView()
    private let smallTitle = UILabel()
    private lazy var items: [StatItem] = [
        .init(title: NSLocalizedString("statsBestPeriodTitle", comment: "Лучший период"),     value: "—", color: blue),
        .init(title: NSLocalizedString("statsPerfectDaysTitle", comment: "Идеальные дни"),     value: "0", color: green),
        .init(title: NSLocalizedString("statsCompletedTrackersTitle", comment: "Трекеров завершено"),value: "0", color: red),
        .init(title: NSLocalizedString("statsAverageValueTitle", comment: "Среднее значение"),  value: "0", color: blue)
    ]
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .systemBackground
        setupUI()
        bindViewModel()
        recalcStatsAndReload()
    }
    
    private func setupUI() {
        view.addSubviews(largeTitle, tableView)
        [largeTitle, tableView].disableAutoResizingMasks()
        setupTable()
        setupLargeTitle()
        setupConstraints()
    }
    
    private func setupLargeTitle() {
        largeTitle.text = NSLocalizedString("statsTitle", comment: "Статистика")
        largeTitle.font = .systemFont(ofSize: 34, weight: .bold)
        largeTitle.textColor = .label
    }
    
    private func setupTable() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 90
        tableView.register(StatsCardCell.self, forCellReuseIdentifier: "StatsCardCell")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            largeTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            largeTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.topAnchor.constraint(equalTo: largeTitle.bottomAnchor, constant: 77),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupEmptyState() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        smallTitle.translatesAutoresizingMaskIntoConstraints = false
        
        image.image = UIImage(resource: .statsEmoji)
        smallTitle.text = NSLocalizedString("statsEmtySmallTitle", comment: "Анализировать пока нечего")
        smallTitle.font = .systemFont(ofSize: 12)
        smallTitle.textColor = .label
        smallTitle.textAlignment = .center
        
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
    
    private func bindViewModel() {
        viewModel.onCategoriesUpdated = { [weak self] _ in self?.recalcStatsAndReload() }
        viewModel.onCompletedTrackersUpdated = { [weak self] _ in self?.recalcStatsAndReload() }
    }
    
    private func recalcStatsAndReload() {
        let stats = computeStats()
        items[0] = .init(title: NSLocalizedString("statsBestPeriodTitle", comment: "Лучший период"),      value: stats.bestPeriodDays > 0 ? "\(stats.bestPeriodDays)" : "—", color: blue)
        items[1] = .init(title: NSLocalizedString("statsPerfectDaysTitle", comment: "Идеальные дни"),      value: "\(stats.perfectDays)",    color: green)
        items[2] = .init(title: NSLocalizedString("statsCompletedTrackersTitle", comment: "Трекеров завершено"), value: "\(stats.totalCompleted)", color: red)
        items[3] = .init(title: NSLocalizedString("statsAverageValueTitle", comment: "Среднее значение"),   value: stats.averagePerDay > 0 ? String(format: "%.1f", stats.averagePerDay) : "0", color: blue)
        
        let isEmpty = stats.totalCompleted == 0
        tableView.isHidden = isEmpty
        if isEmpty {
            if emptyStateView.superview == nil { setupEmptyState() }
            emptyStateView.isHidden = false
        } else {
            emptyStateView.isHidden = true
        }
        
        tableView.reloadData()
    }
    
    private func computeStats() -> StatsSummary {
        let records = Array(viewModel.completedTrackers)
        let trackers = viewModel
            .categories
            .flatMap { $0.trackers }
        
        let cal = Calendar.current
        func startOfDay(_ d: Date) -> Date { cal.startOfDay(for: d) }
        let doneByDay: [Date: Set<UUID>] = records.reduce(into: [:]) { dict, rec in
            let day = startOfDay(rec.date)
            var set = dict[day] ?? Set<UUID>()
            set.insert(rec.id)
            dict[day] = set
        }
        
        if doneByDay.isEmpty {
            return .init(bestPeriodDays: 0, perfectDays: 0, totalCompleted: 0, averagePerDay: 0)
        }
        
        func weekDay(for d: Date) -> WeekDay {
            let wd = cal.component(.weekday, from: d)
            return WeekDay(rawValue: (wd + 5) % 7 + 1) ?? .monday
        }
        func scheduledIDs(on d: Date) -> Set<UUID> {
            let wd = weekDay(for: d)
            return Set(trackers
                .filter { !$0.schedule.isEmpty && $0.schedule.contains(wd) }
                .map { $0.id })
        }
        
        var perfect = 0
        for (day, completed) in doneByDay {
            let scheduled = scheduledIDs(on: day)
            guard !scheduled.isEmpty else { continue }
            if completed.count == scheduled.count && completed.isSuperset(of: scheduled) {
                perfect += 1
            }
        }
        
        let sortedDays = doneByDay.keys.map(startOfDay).sorted()
        var bestStreak = 1
        var streak = 1
        for i in 1..<sortedDays.count {
            if let next = cal.date(byAdding: .day, value: 1, to: sortedDays[i-1]),
               next == sortedDays[i] {
                streak += 1
                bestStreak = max(bestStreak, streak)
            } else {
                streak = 1
            }
        }
        
        let totalCompleted = records.count
        let activeDays = doneByDay.count
        let average = activeDays > 0 ? Double(totalCompleted) / Double(activeDays) : 0
        
        return .init(bestPeriodDays: bestStreak,
                     perfectDays: perfect,
                     totalCompleted: totalCompleted,
                     averagePerDay: average)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int { items.count }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatsCardCell", for: indexPath) as! StatsCardCell
        let item = items[indexPath.section]
        cell.configure(title: item.title, value: item.value,
                       gradientColors: [blue, green, red],
                       width: 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == items.count - 1 ? 0 : 12
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section != items.count - 1 else { return nil }
        let v = UIView(); v.backgroundColor = .clear
        return v
    }
}
