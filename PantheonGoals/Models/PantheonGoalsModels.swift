import Foundation

// MARK: - Artifact Model
struct PantheonGoalsArtifact: Codable {
    let id: String
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var imageName: String
    var deadline: Date?
    var contributions: [PantheonGoalsContribution]
    var isCompleted: Bool
    
    init(id: String = UUID().uuidString,
         name: String,
         targetAmount: Double,
         imageName: String,
         deadline: Date? = nil) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = 0
        self.imageName = imageName
        self.deadline = deadline
        self.contributions = []
        self.isCompleted = false
    }
    
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
}

// MARK: - Contribution Model
struct PantheonGoalsContribution: Codable {
    let id: String
    let amount: Double
    let date: Date
    let comment: String?
    
    init(id: String = UUID().uuidString,
         amount: Double,
         comment: String? = nil) {
        self.id = id
        self.amount = amount
        self.date = Date()
        self.comment = comment
    }
}

// MARK: - Achievement Model
struct PantheonGoalsAchievement: Codable {
    let id: String
    let title: String
    let description: String
    let imageName: String
    var isUnlocked: Bool
    
    static let allAchievements: [PantheonGoalsAchievement] = [
        PantheonGoalsAchievement(id: "first_step",
                                title: "First Step",
                                description: "Create your first artifact",
                                imageName: "rewardOne",
                                isUnlocked: false),
        PantheonGoalsAchievement(id: "collector",
                                title: "Collector",
                                description: "Have 3 active artifacts",
                                imageName: "rewardTwo",
                                isUnlocked: false),
        PantheonGoalsAchievement(id: "completed_artifact",
                                title: "Completed Artifact",
                                description: "Reach a goal at least once",
                                imageName: "rewardThree",
                                isUnlocked: false),
        PantheonGoalsAchievement(id: "on_time",
                                title: "On Time",
                                description: "Finish a goal exactly on its deadline",
                                imageName: "rewardFour",
                                isUnlocked: false),
        PantheonGoalsAchievement(id: "strength_of_athena",
                                title: "Strength of Athena",
                                description: "Reach all achievements",
                                imageName: "rewardFive",
                                isUnlocked: false)
    ]
}
