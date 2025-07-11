import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(windowScene: windowScene)
        
        self.window?.makeKeyAndVisible()
        
        if UserDefaults.standard.bool(forKey: "onboardingCompleted") {
            window?.rootViewController = TabBarViewController()
        } else {
            window?.rootViewController = OnboardingViewController()
        }
        
    }
}

