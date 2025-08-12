import Foundation
import AppMetricaCore

enum AnalyticsEvent: String {
    case open, close, click
}

enum AnalyticsScreen: String {
    case main = "Main"
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track    = "track"
    case filter   = "filter"
    case edit     = "edit"
    case delete   = "delete"
}

enum Analytics {
#if DEBUG
    static var testReporter: ((String, [String: Any]) -> Void)?
#endif
    
    static func send(_ event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem? = nil) {
        var params: [String: Any] = [
            "event": event.rawValue,
            "screen": screen.rawValue
        ]
        if let item { params["item"] = item.rawValue }
        
#if DEBUG
        print("📊 Analytics:", params)
        testReporter?("ui_event", params)
#endif
        
        AppMetrica.reportEvent(name: "ui_event", parameters: params)
    }
}
