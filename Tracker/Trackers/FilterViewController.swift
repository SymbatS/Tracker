import UIKit

final class FilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let options: [TrackerFilter] = [.all, .today, .completed, .incomplete]
    private let onSelect: (TrackerFilter) -> Void
    private let selectedFilter: TrackerFilter?
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    init(selected: TrackerFilter?, onSelect: @escaping (TrackerFilter) -> Void) {
        self.selectedFilter = selected
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        let label = UILabel()
        label.text = NSLocalizedString("filterTitle", comment: "Фильтры")
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        navigationItem.titleView = label
        
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupTableView() {
        view.backgroundColor = .white
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.rowHeight = 75
        tableView.register(FilterOptionCell.self, forCellReuseIdentifier: "FilterOptionCell")
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { options.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let opt = options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterOptionCell", for: indexPath) as! FilterOptionCell
        
        let text: String = {
            switch opt {
            case .all:        return NSLocalizedString("filterAll", comment: "Все трекеры")
            case .today:      return NSLocalizedString("filterToday", comment: "Трекеры на сегодня")
            case .completed:  return NSLocalizedString("filterCompleted", comment: "Завершённые")
            case .incomplete: return NSLocalizedString("filterInComplete", comment: "Незавершённые")
            }
        }()
        
        let checked = (opt == .completed || opt == .incomplete) && (opt == selectedFilter)
        cell.configure(text: text,
                       isLast: indexPath.row == options.count - 1,
                       checked: checked)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let opt = options[indexPath.row]
        dismiss(animated: true) { [onSelect] in onSelect(opt) }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let total = tableView.numberOfRows(inSection: indexPath.section)
        
        let radius: CGFloat = 16
        var corners: CACornerMask = []
        if indexPath.row == 0 {
            corners.formUnion([.layerMinXMinYCorner, .layerMaxXMinYCorner])
        }
        if indexPath.row == total - 1 {
            corners.formUnion([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        }
        
        cell.contentView.layer.cornerRadius = corners.isEmpty ? 0 : radius
        cell.contentView.layer.maskedCorners = corners
        cell.contentView.layer.masksToBounds = !corners.isEmpty
    }
}
