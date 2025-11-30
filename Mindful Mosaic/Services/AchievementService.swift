import Foundation

struct Achievement: Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String
    var isUnlocked: Bool
    let requirement: AchievementRequirement
    
    enum AchievementRequirement {
        case streak(days: Int)
        case totalCheckIns(count: Int)
        case activityCount(activity: String, count: Int)
        case emotionCount(emotion: String, count: Int)
    }
}

class AchievementService {
    static let shared = AchievementService()
    
    private let checkInService = CheckInService.shared
    private let unlockedAchievementsKey = "unlocked_achievements"
    
    private init() {}
    
    func getAllAchievements() -> [Achievement] {
        let allAchievements = [
            Achievement(id: "first_checkin", name: "First Step", icon: "star.fill", description: "Complete your first check-in", isUnlocked: false, requirement: .totalCheckIns(count: 1)),
            Achievement(id: "week_streak", name: "Week Warrior", icon: "flame.fill", description: "Maintain a 7-day streak", isUnlocked: false, requirement: .streak(days: 7)),
            Achievement(id: "meditation_master", name: "Meditation Master", icon: "leaf.fill", description: "Meditate 10 times", isUnlocked: false, requirement: .activityCount(activity: "Meditation", count: 10)),
            Achievement(id: "exercise_enthusiast", name: "Exercise Enthusiast", icon: "figure.run", description: "Exercise 15 times", isUnlocked: false, requirement: .activityCount(activity: "Exercise", count: 15)),
            Achievement(id: "joy_seeker", name: "Joy Seeker", icon: "heart.fill", description: "Feel joy 20 times", isUnlocked: false, requirement: .emotionCount(emotion: "Joy", count: 20)),
            Achievement(id: "month_streak", name: "Monthly Champion", icon: "crown.fill", description: "Maintain a 30-day streak", isUnlocked: false, requirement: .streak(days: 30))
        ]
        
        let unlockedIds = getUnlockedAchievementIds()
        
        return allAchievements.map { achievement in
            var updated = achievement
            updated.isUnlocked = unlockedIds.contains(achievement.id) || checkRequirement(achievement.requirement)
            if updated.isUnlocked && !unlockedIds.contains(achievement.id) {
                unlockAchievement(achievement.id)
            }
            return updated
        }
    }
    
    private func checkRequirement(_ requirement: Achievement.AchievementRequirement) -> Bool {
        switch requirement {
        case .streak(let days):
            return checkInService.getCurrentStreak() >= days
        case .totalCheckIns(let count):
            return checkInService.getAllCheckIns().count >= count
        case .activityCount(let activity, let count):
            let checkIns = checkInService.getAllCheckIns()
            let activityCount = checkIns.reduce(0) { $0 + ($1.activities.contains(activity) ? 1 : 0) }
            return activityCount >= count
        case .emotionCount(let emotion, let count):
            let checkIns = checkInService.getAllCheckIns()
            let emotionCount = checkIns.filter { $0.emotion == emotion }.count
            return emotionCount >= count
        }
    }
    
    private func getUnlockedAchievementIds() -> Set<String> {
        guard let data = UserDefaults.standard.data(forKey: unlockedAchievementsKey),
              let ids = try? JSONDecoder().decode(Set<String>.self, from: data) else {
            return []
        }
        return ids
    }
    
    private func unlockAchievement(_ id: String) {
        var unlocked = getUnlockedAchievementIds()
        unlocked.insert(id)
        if let encoded = try? JSONEncoder().encode(unlocked) {
            UserDefaults.standard.set(encoded, forKey: unlockedAchievementsKey)
        }
    }
}

