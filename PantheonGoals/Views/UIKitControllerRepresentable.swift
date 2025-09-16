import SwiftUI

struct UIKitControllerRepresentable: UIViewControllerRepresentable {
    let viewController: UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        // Ensure the view controller doesn't adjust its view insets automatically
        if #available(iOS 11.0, *) {
            viewController.additionalSafeAreaInsets = .zero
            viewController.view.insetsLayoutMarginsFromSafeArea = false
        }
        
        // Make sure content isn't clipped
        viewController.view.clipsToBounds = false
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
