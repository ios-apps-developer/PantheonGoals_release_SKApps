import UIKit
import AdkLib
import SwiftUI

@main
final class AppDelegate: AdkLib.AppDelegate {
    
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
                .edgesIgnoringSafeArea(.all)
        }
        
        let hostingController = UIHostingController(rootView: remoteScreen)
        hostingController.view.backgroundColor = .clear
        
        // Ensure the hosting controller doesn't clip content
        if #available(iOS 11.0, *) {
            hostingController.additionalSafeAreaInsets = .zero
        }
        
        window?.rootViewController = hostingController
        window?.makeKeyAndVisible()
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        return true
    }

}
