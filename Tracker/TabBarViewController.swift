import UIKit

final class TabBarViewController: UITabBarController {
    private enum TabBarItem: Int {
        case trackers
        case stats
        var title: String {
            switch self {
            case .trackers:
                return "Трекеры"
            case .stats:
                return "Статистика"
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
        
        let dataSource: [TabBarItem] = [.trackers, .stats]
        
        self.viewControllers = dataSource.map {
            
            switch $0 {
                
            case .trackers:
                let trackersViewController = TrackersViewController()
                return self.wrappedInNavigationController(with: trackersViewController, title: $0.title)
            case .stats:
                let statsViewController = StatsViewController()
                return self.wrappedInNavigationController(with: statsViewController, title: $0.title)
            }
        }
        self.viewControllers?.enumerated().forEach {

                    $1.tabBarItem.title = dataSource[$0].title
                    $1.tabBarItem.image = UIImage(named: dataSource[$0].iconName)
                    $1.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: .zero, bottom: -5, right: .zero)
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
