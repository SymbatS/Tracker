import UIKit

protocol EditTrackerDelegate: AnyObject {
    func didUpdateTracker(_ tracker: Tracker)
}

final class EditTrackerViewController: UIViewController {
    
    private let tracker: Tracker
    private let completedDays: Int
    weak var delegate: CreateTrackerDelegate?
    
    init(tracker: Tracker, completedDays: Int) {
        self.tracker = tracker
        self.completedDays = completedDays
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Редактирование привычки"
        view.backgroundColor = .white
        
        setupUI()
    }
    
    private func setupUI() {
        let countLabel = UILabel()
        countLabel.text = "\(completedDays) дней"
        countLabel.textAlignment = .center
        countLabel.font = .systemFont(ofSize: 32, weight: .bold)
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(countLabel)
        
        let trackerConfig = TrackerFormConfiguration(tracker: tracker)
        let formVC = TrackerFormViewController(config: trackerConfig)
        formVC.delegate = self
        
        addChild(formVC)
        view.addSubview(formVC.view)
        formVC.didMove(toParent: self)
        formVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            countLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            formVC.view.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 16),
            formVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            formVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            formVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - CreateTrackerDelegate

extension EditTrackerViewController: CreateTrackerDelegate {
    func didUpdateTracker(_ tracker: Tracker) {
        delegate?.didUpdateTracker(tracker)
    }
    
    func didCreateTracker(_ tracker: Tracker) {
        delegate?.didUpdateTracker(tracker)
    }
    
    func didFinishCreation() {
        navigationController?.popViewController(animated: true)
    }
}
