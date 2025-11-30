import Foundation

class CheckInService {
    static let shared = CheckInService()
    
    private let checkInsKey = "saved_check_ins"
    
    private init() {}
    
    func saveCheckIn(_ checkIn: CheckInData) {
        var checkIns = getAllCheckIns()
        checkIns.append(checkIn)
        
        if let encoded = try? JSONEncoder().encode(checkIns) {
            UserDefaults.standard.set(encoded, forKey: checkInsKey)
            NotificationCenter.default.post(name: NSNotification.Name("CheckInSaved"), object: nil)
        }
    }
    
    func getAllCheckIns() -> [CheckInData] {
        guard let data = UserDefaults.standard.data(forKey: checkInsKey),
              let checkIns = try? JSONDecoder().decode([CheckInData].self, from: data) else {
            return []
        }
        return checkIns
    }
    
    func getCheckInsForLastDays(_ days: Int) -> [CheckInData] {
        let allCheckIns = getAllCheckIns()
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return allCheckIns.filter { $0.date >= cutoffDate }
    }
    
    func getCurrentStreak() -> Int {
        let checkIns = getAllCheckIns().sorted { $0.date > $1.date }
        guard !checkIns.isEmpty else { return 0 }
        
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        for checkIn in checkIns {
            let checkInDate = Calendar.current.startOfDay(for: checkIn.date)
            if checkInDate == currentDate {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if checkInDate < currentDate {
                break
            }
        }
        
        return streak
    }
    
    func getMostCommonEmotion() -> String? {
        let checkIns = getAllCheckIns()
        guard !checkIns.isEmpty else { return nil }
        
        let emotionCounts = Dictionary(grouping: checkIns, by: { $0.emotion })
            .mapValues { $0.count }
        
        return emotionCounts.max(by: { $0.value < $1.value })?.key
    }
    
    func getFavoriteActivity() -> String? {
        let checkIns = getAllCheckIns()
        guard !checkIns.isEmpty else { return nil }
        
        var activityCounts: [String: Int] = [:]
        for checkIn in checkIns {
            for activity in checkIn.activities {
                activityCounts[activity, default: 0] += 1
            }
        }
        
        return activityCounts.max(by: { $0.value < $1.value })?.key
    }
    
    func getWeeklyCheckIns() -> [Int] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var weeklyCounts: [Int] = []
        
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let checkIns = getAllCheckIns().filter {
                calendar.isDate($0.date, inSameDayAs: date)
            }
            weeklyCounts.append(checkIns.count)
        }
        
        return weeklyCounts.reversed()
    }
}

