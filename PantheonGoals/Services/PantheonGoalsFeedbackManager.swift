import UIKit
import AudioToolbox

final class PantheonGoalsFeedbackManager {
    static let shared = PantheonGoalsFeedbackManager()
    
    private init() {}
    
    func playButtonSound() {
        if PantheonGoalsStorageManager.shared.isSoundEnabled {
            AudioServicesPlaySystemSound(1104)
        }
    }
    
    func playHaptic() {
        if PantheonGoalsStorageManager.shared.isHapticEnabled {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        }
    }
    
    func buttonFeedback() {
        playButtonSound()
        playHaptic()
    }
}
