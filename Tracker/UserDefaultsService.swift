import Foundation

final class UserDefaultsService {
    static let shared = UserDefaultsService()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    private enum Key {
        static let onboardingCompleted = "onboardingCompleted"
        static let trackerFilter = "trackerFilter"
    }
    
    var isOnboardingCompleted: Bool {
        get { defaults.bool(forKey: Key.onboardingCompleted) }
        set { defaults.set(newValue, forKey: Key.onboardingCompleted) }
    }
    
    var trackerFilterRawValue: String? {
        get { defaults.string(forKey: Key.trackerFilter) }
        set { defaults.set(newValue, forKey: Key.trackerFilter) }
    }
}
