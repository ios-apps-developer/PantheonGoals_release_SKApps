import Foundation
import AppsFlyerLib
import OneSignalFramework

class AppLinkManager {
    static let shared = AppLinkManager()
    
    private init() {}
    
    func createStartLink() {
        // Instead of duplicating URL construction, use the existing flow
        AppParameters.shared.processLink()
    }
} 