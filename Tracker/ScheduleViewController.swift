import UIKit

final class ScheduleViewController: UIViewController {
    
    private let days = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    private var selectedDays: Set<WeekDay> = []
    var onSave: ((Set<WeekDay>) -> Void)?
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let doneButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Выбор расписания"
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        
        setupTableView()
        setupDoneButton()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.rowHeight = 75
        tableView.register(DayCell.self, forCellReuseIdentifier: "DayCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -88)
        ])
    }
    
    private func setupDoneButton() {
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = .black
        doneButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        doneButton.layer.cornerRadius = 16
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func doneTapped() {
        onSave?(selectedDays)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableView

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell", for: indexPath) as? DayCell else {
            return UITableViewCell()
        }
        
        let weekday = WeekDay(rawValue: indexPath.row + 1)!
        let isSelected = selectedDays.contains(weekday)
        
        cell.configure(day: days[indexPath.row], isOn: isSelected)
        cell.switchChanged = { [weak self] isOn in
            guard let self else { return }
            if isOn {
                selectedDays.insert(weekday)
            } else {
                selectedDays.remove(weekday)
            }
        }
        
        return cell
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
    }
    
}
