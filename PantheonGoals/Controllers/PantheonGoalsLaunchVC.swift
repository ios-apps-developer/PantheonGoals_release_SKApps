import UIKit
import SnapKit

final class PantheonGoalsLaunchVC: UIViewController {
    
    // MARK: - UI Elements
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pahntheonBackground")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let loaderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "copilSeven")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.textColor = .white
        label.font = .pantheonGoalsFont(size: 24)
        label.alpha = 0
        return label
    }()
    
    private let transitionView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pahntheonBackground")
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0
        return imageView
    }()
    
    // MARK: - Properties
    private var loaderAnimation: CABasicAnimation?
    private var labelAnimation: CABasicAnimation?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startLoadingAnimation()
        
        // Simulate loading and transition to main screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.prepareForTransition()
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubviews(backgroundImageView, loaderImageView, loadingLabel, transitionView)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loaderImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        loadingLabel.snp.makeConstraints { make in
            make.top.equalTo(loaderImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        transitionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Animations
    private func startLoadingAnimation() {
        // Loader animation
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.2
        scaleAnimation.duration = 0.8
        scaleAnimation.autoreverses = true
        scaleAnimation.repeatCount = .infinity
        loaderImageView.layer.add(scaleAnimation, forKey: "scale")
        
        // Alpha animation
        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.fromValue = 1.0
        alphaAnimation.toValue = 0.6
        alphaAnimation.duration = 0.8
        alphaAnimation.autoreverses = true
        alphaAnimation.repeatCount = .infinity
        loaderImageView.layer.add(alphaAnimation, forKey: "opacity")
        
        // Loading label animation
        UIView.animate(withDuration: 0.5) {
            self.loadingLabel.alpha = 1
        }
    }
    
    private func prepareForTransition() {
        // Show transition view
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.transitionView.alpha = 1
        } completion: { [weak self] _ in
            self?.transitionToMainScreen()
        }
    }
    
    private func transitionToMainScreen() {
        // Setup main navigation
        let mainVC = PantheonGoalsMainVC()
        let navigationController = UINavigationController(rootViewController: mainVC)
        navigationController.isNavigationBarHidden = true
        
        // Switch root view controller
        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = navigationController
    }
}
