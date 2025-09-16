import Foundation

final class PantheonGoalsStorageManager {
    static let shared = PantheonGoalsStorageManager()
    private let defaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Keys {
        static let isFirstLaunch = "PantheonGoals_IsFirstLaunch"
        static let soundEnabled = "PantheonGoals_SoundEnabled"
        static let hapticEnabled = "PantheonGoals_HapticEnabled"
        static let notificationsEnabled = "PantheonGoals_NotificationsEnabled"
        static let userName = "PantheonGoals_UserName"
        static let userAvatar = "PantheonGoals_UserAvatar"
        static let artifacts = "PantheonGoals_Artifacts"
        static let achievements = "PantheonGoals_Achievements"
    }
    
    private init() {}
    
    // MARK: - First Launch
    var isFirstLaunch: Bool {
        get {
            defaults.bool(forKey: Keys.isFirstLaunch)
        }
        set {
            defaults.set(newValue, forKey: Keys.isFirstLaunch)
        }
    }
    
    // MARK: - Settings
    var isSoundEnabled: Bool {
        get {
            defaults.bool(forKey: Keys.soundEnabled)
        }
        set {
            defaults.set(newValue, forKey: Keys.soundEnabled)
        }
    }
    
    var isHapticEnabled: Bool {
        get {
            defaults.bool(forKey: Keys.hapticEnabled)
        }
        set {
            defaults.set(newValue, forKey: Keys.hapticEnabled)
        }
    }
    
    var isNotificationsEnabled: Bool {
        get {
            defaults.bool(forKey: Keys.notificationsEnabled)
        }
        set {
            defaults.set(newValue, forKey: Keys.notificationsEnabled)
        }
    }
    
    // MARK: - User Profile
    var userName: String {
        get {
            defaults.string(forKey: Keys.userName) ?? "User"
        }
        set {
            defaults.set(newValue, forKey: Keys.userName)
        }
    }
    
    var userAvatar: String {
        get {
            defaults.string(forKey: Keys.userAvatar) ?? "avatarOne"
        }
        set {
            defaults.set(newValue, forKey: Keys.userAvatar)
        }
    }
    
    // MARK: - Artifacts
    func saveArtifacts(_ artifacts: [PantheonGoalsArtifact]) {
        if let encoded = try? JSONEncoder().encode(artifacts) {
            defaults.set(encoded, forKey: Keys.artifacts)
        }
    }
    
    func loadArtifacts() -> [PantheonGoalsArtifact] {
        guard let data = defaults.data(forKey: Keys.artifacts),
              let artifacts = try? JSONDecoder().decode([PantheonGoalsArtifact].self, from: data) else {
            return []
        }
        return artifacts
    }
    
    // MARK: - Achievements
    func saveAchievements(_ achievements: [PantheonGoalsAchievement]) {
        if let encoded = try? JSONEncoder().encode(achievements) {
            defaults.set(encoded, forKey: Keys.achievements)
        }
    }
    
    func loadAchievements() -> [PantheonGoalsAchievement] {
        guard let data = defaults.data(forKey: Keys.achievements),
              let achievements = try? JSONDecoder().decode([PantheonGoalsAchievement].self, from: data) else {
            // Return locked achievements if none saved
            var achievements = PantheonGoalsAchievement.allAchievements
            for i in 0..<achievements.count {
                achievements[i].isUnlocked = false
            }
            return achievements
        }
        return achievements
    }
    
    // MARK: - Setup Default Values
    func setupDefaultValues() {
        if !defaults.bool(forKey: "PantheonGoals_DefaultsConfigured") {
            isFirstLaunch = true
            isSoundEnabled = true
            isHapticEnabled = true
            isNotificationsEnabled = false
            userName = "User"
            userAvatar = "avatarOne"
            
            // Initialize achievements as locked only on first launch
            var achievements = PantheonGoalsAchievement.allAchievements
            for i in 0..<achievements.count {
                achievements[i].isUnlocked = false
            }
            saveAchievements(achievements)
            
            defaults.set(true, forKey: "PantheonGoals_DefaultsConfigured")
        }
    }
    
    // MARK: - Reset Achievements (for testing)
    func resetAchievements() {
        var achievements = PantheonGoalsAchievement.allAchievements
        for i in 0..<achievements.count {
            achievements[i].isUnlocked = false
        }
        saveAchievements(achievements)
    }
}
