import UIKit

final class TabBarViewController: UITabBarController {
    private enum TabBarItem: Int {
        case trackers
        case stats
        var title: String {
            switch self {
            case .trackers:
                return NSLocalizedString("trackersTitle", comment: "Трекеры")
            case .stats:
                return NSLocalizedString("statsTitle", comment: "Статистика")
            }
            
        }
        var iconName: String {
            switch self {
            case .trackers:
                return "Trackers"
            case .stats:
                return "Stats"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addSeparatorLine()
    }
    
    private func setupTabBar() {
        let context = CoreDataStack.shared.context
        
        let trackerStore = TrackerStore(context: context)
        let trackerCategoryStore = TrackerCategoryStore(context: context)
        let trackerRecordStore = TrackerRecordStore(context: context)
        
        let viewModel = TrackersViewModel(
            trackerStore: trackerStore,
            trackerCategoryStore: trackerCategoryStore,
            trackerRecordStore: trackerRecordStore
        )
        
        let trackersVC = TrackersViewController(viewModel: viewModel)
        let statsVC = StatsViewController(viewModel: viewModel)
        
        viewControllers = [
            wrappedInNavigationController(with: trackersVC, title: NSLocalizedString("trackersTitle", comment: "Трекеры")),
            wrappedInNavigationController(with: statsVC, title: NSLocalizedString("statsTitle", comment: "Статистика"))
        ]
        
        viewControllers?.enumerated().forEach {
            let item = TabBarItem(rawValue: $0)!
            $1.tabBarItem.title = item.title
            $1.tabBarItem.image = UIImage(named: item.iconName)
            $1.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        }
    }
    
    private func addSeparatorLine() {
        let separator = UIView()
        separator.backgroundColor = .lightGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        tabBar.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: tabBar.topAnchor),
            separator.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    private func wrappedInNavigationController(with: UIViewController, title: Any?) -> UINavigationController {
        return UINavigationController(rootViewController: with)
    }
}
