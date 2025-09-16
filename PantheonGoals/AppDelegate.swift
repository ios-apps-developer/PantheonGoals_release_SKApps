import UIKit
import AdkLib
import SwiftUI

@main
final class AppDelegate: AdkLib.AppDelegate {
    var appOrientation: UIInterfaceOrientationMask = .portrait
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Call super to initialize AdkLib
        super.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        PantheonGoalsStorageManager.shared.setupDefaultValues()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainVC = PantheonGoalsMainVC()
        let navController = UINavigationController(rootViewController: mainVC)
        navController.isNavigationBarHidden = true
        
        let remoteScreen = RemoteScreen {
            UIKitControllerRepresentable(viewController: navController)
        }
        
        let hostingController = UIHostingController(rootView: remoteScreen)
        window?.rootViewController = hostingController
        window?.makeKeyAndVisible()
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        return true
    }

}
