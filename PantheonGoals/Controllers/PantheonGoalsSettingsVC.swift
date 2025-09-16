import UIKit
import SnapKit
import StoreKit
import UserNotifications

final class PantheonGoalsSettingsVC: UIViewController {
    
    // MARK: - UI Elements
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pahntheonBackground")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let backButton: PantheonGoalsButton = {
        let button = PantheonGoalsButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.textColor = .white
        label.font = .pantheonGoalsFont(size: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .pantheonGoalsBeige.withAlphaComponent(0.9)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let soundLabel: UILabel = {
        let label = UILabel()
        label.text = "Sound"
        label.textColor = .pantheonGoalsDarkPurple
        label.font = .pantheonGoalsFont(size: 18)
        return label
    }()
    
    private let soundSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .pantheonGoalsGold
        return toggle
    }()
    
    private let hapticLabel: UILabel = {
        let label = UILabel()
        label.text = "Vibration"
        label.textColor = .pantheonGoalsDarkPurple
        label.font = .pantheonGoalsFont(size: 18)
        return label
    }()
    
    private let hapticSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .pantheonGoalsGold
        return toggle
    }()
    
    private let notificationsLabel: UILabel = {
        let label = UILabel()
        label.text = "Notifications"
        label.textColor = .pantheonGoalsDarkPurple
        label.font = .pantheonGoalsFont(size: 18)
        return label
    }()
    
    private let notificationsSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .pantheonGoalsGold
        return toggle
    }()
    
    private let rateButton: PantheonGoalsButton = {
        let button = PantheonGoalsButton()
        button.setTitle("Rate Us", for: .normal)
        button.backgroundColor = .pantheonGoalsGold
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        loadSettings()
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationController?.isNavigationBarHidden = true
        
        view.addSubviews(backgroundImageView, backButton, titleLabel, containerView, rateButton)
        containerView.addSubviews(soundLabel, soundSwitch, hapticLabel, hapticSwitch, notificationsLabel, notificationsSwitch)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.centerX.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        soundLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(24)
        }
        
        soundSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(soundLabel)
            make.trailing.equalToSuperview().offset(-24)
        }
        
        hapticLabel.snp.makeConstraints { make in
            make.top.equalTo(soundLabel.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(24)
        }
        
        hapticSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(hapticLabel)
            make.trailing.equalToSuperview().offset(-24)
        }
        
        notificationsLabel.snp.makeConstraints { make in
            make.top.equalTo(hapticLabel.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        notificationsSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(notificationsLabel)
            make.trailing.equalToSuperview().offset(-24)
        }
        
        rateButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        rateButton.addTarget(self, action: #selector(rateButtonTapped), for: .touchUpInside)
        
        soundSwitch.addTarget(self, action: #selector(soundSwitchChanged), for: .valueChanged)
        hapticSwitch.addTarget(self, action: #selector(hapticSwitchChanged), for: .valueChanged)
        notificationsSwitch.addTarget(self, action: #selector(notificationsSwitchChanged), for: .valueChanged)
    }
    
    private func loadSettings() {
        soundSwitch.isOn = PantheonGoalsStorageManager.shared.isSoundEnabled
        hapticSwitch.isOn = PantheonGoalsStorageManager.shared.isHapticEnabled
        
        // Check actual notification authorization status
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                let isAuthorized = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
                self?.notificationsSwitch.isOn = isAuthorized && PantheonGoalsStorageManager.shared.isNotificationsEnabled
            }
        }
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func rateButtonTapped() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        guard let scene = view.window?.windowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
    
    
    @objc private func soundSwitchChanged() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        PantheonGoalsStorageManager.shared.isSoundEnabled = soundSwitch.isOn
    }
    
    @objc private func hapticSwitchChanged() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        PantheonGoalsStorageManager.shared.isHapticEnabled = hapticSwitch.isOn
    }
    
    @objc private func notificationsSwitchChanged() {
        PantheonGoalsFeedbackManager.shared.buttonFeedback()
        
        if notificationsSwitch.isOn {
            UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
                DispatchQueue.main.async {
                    switch settings.authorizationStatus {
                    case .notDetermined:
                        self?.requestNotificationPermission()
                    case .denied:
                        self?.showNotificationSettingsAlert()
                        self?.notificationsSwitch.isOn = false
                        PantheonGoalsStorageManager.shared.isNotificationsEnabled = false
                    case .authorized, .provisional, .ephemeral:
                        self?.scheduleNotifications()
                        PantheonGoalsStorageManager.shared.isNotificationsEnabled = true
                    @unknown default:
                        break
                    }
                }
            }
        } else {
            removeAllNotifications()
            PantheonGoalsStorageManager.shared.isNotificationsEnabled = false
        }
    }
    
    // MARK: - Notifications
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                if granted {
                    self?.scheduleNotifications()
                    PantheonGoalsStorageManager.shared.isNotificationsEnabled = true
                } else {
                    self?.notificationsSwitch.isOn = false
                    PantheonGoalsStorageManager.shared.isNotificationsEnabled = false
                }
            }
        }
    }
    
    private func scheduleNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "PantheonGoals"
        content.body = "Time to check your artifacts!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2 * 24 * 60 * 60, repeats: true)
        let request = UNNotificationRequest(identifier: "PantheonGoals_Reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func showNotificationSettingsAlert() {
        let alert = UIAlertController(
            title: "Notifications Disabled",
            message: "Please enable notifications in Settings to receive reminders.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
