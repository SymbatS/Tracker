import UIKit
import AppMetricaCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        
        if UserDefaultsService.shared.isOnboardingCompleted {
            window?.rootViewController = TabBarViewController()
        } else {
            window?.rootViewController = OnboardingViewController()
        }
        if let configuration = AppMetricaConfiguration(apiKey: "51d3a690-efcf-47d0-b44b-9fd5df38562d") {
            AppMetrica.activate(with: configuration)
        }
        window?.makeKeyAndVisible()
        return true
    }
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
