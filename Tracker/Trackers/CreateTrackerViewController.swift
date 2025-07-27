import UIKit

protocol CreateTrackerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker)
    func didUpdateTracker(_ tracker: Tracker)
    func didFinishCreation()
}

final class CreateTrackerViewController: UIViewController {
    
    weak var delegate: CreateTrackerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI(){
        view.backgroundColor = .white
        title = "Создание трекера"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16)
        ]
        
        let habitButton = UIButton(type: .system)
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.setTitleColor(.white, for: .normal)
        habitButton.backgroundColor = .black
        habitButton.layer.cornerRadius = 16
        habitButton.addTarget(self, action: #selector(handleCreateHabit), for: .touchUpInside)
        view.addSubview(habitButton)
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        
        let eventButton = UIButton(type: .system)
        eventButton.setTitle( "Нерегулярное событие", for: .normal)
        eventButton.setTitleColor(.white, for: .normal)
        eventButton.backgroundColor = .black
        eventButton.layer.cornerRadius = 16
        eventButton.addTarget(self, action: #selector(handleCreateEvent), for: .touchUpInside)
        view.addSubview(eventButton)
        eventButton.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [habitButton, eventButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            eventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func handleCreateHabit(){
        let habitVC = TrackerFormViewController(config: .init(type: .habit, title: "Новая привычка", showSchedule: true))
        habitVC.delegate = self.delegate
        navigationController?.pushViewController(habitVC, animated: true)
        
    }
    
    @objc private func handleCreateEvent() {
        let eventVC = TrackerFormViewController(config: .init(type: .event, title: "Новое нерегулярное событие", showSchedule: false))
        eventVC.delegate = self.delegate
        navigationController?.pushViewController(eventVC, animated: true)
    }
    
}
