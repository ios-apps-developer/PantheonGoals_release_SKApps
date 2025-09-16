import Foundation

public struct AppConfig {
    // SDK Keys
    public static let oneSignalAppId = "d39335be-4422-4b67-82f0-8183ada11848"
    public static let appsFlyerDevKey = "ERb329QqKBZoeVQNzKPCFk"
    public static let appleAppId = "6752373910"
    
    // URLs
    public static let baseUrl = "https://a1686.dev53v1.com/tpiigijt4ydh"
    
    // Date Settings
    public static let contentViewEndDate = Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 1))!
    
    // Alert Texts
    public struct Alert {
        public static let noInternetTitle = "Sorry"
        public static let noInternetMessage = "You must to check correct network's work and relaunch app"
        public static let okButton = "OK"
    }
    
    // UserDefaults Keys
    public struct Keys {
        public static let prefix = "pantefok"
        public static let webViewShown = prefix + "webview_shown"
        public static let targetUrl = prefix + "target_url"
        public static let forceGame = prefix + "force_game"
        public static let checksComplete = prefix + "checks_complete"
        public static let appStatus = prefix + "app_status"
        public static let apiFailed = prefix + "api_failed"
        public static let pushIdentifier = prefix + "push_identifier"
        public static let pushPermissionAsked = prefix + "push_permission_asked"
        public static let cachedToken = prefix + "cached_token"
        public static let deviceId = prefix + "device_id"
        public static let linkProcessed = prefix + "link_processed"
        public static let webKey = prefix + "web_key"
        public static let gameKey = prefix + "game_key"
        public static let cookies = prefix + "cookies"
    }
}
