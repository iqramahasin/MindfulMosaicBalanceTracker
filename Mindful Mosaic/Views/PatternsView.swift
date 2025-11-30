import SwiftUI
import Combine

struct PatternsView: View {
    @StateObject private var viewModel = PatternsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Achievement Collection")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                        ForEach(viewModel.achievements) { achievement in
                            PatternCard(achievement: achievement)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Patterns")
            .onAppear {
                viewModel.loadAchievements()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CheckInSaved"))) { _ in
                viewModel.loadAchievements()
            }
        }
    }
}

class PatternsViewModel: ObservableObject {
    @Published var achievements: [Achievement] = []
    private let achievementService = AchievementService.shared
    
    func loadAchievements() {
        achievements = achievementService.getAllAchievements()
    }
}

struct PatternCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(achievement.isUnlocked ? Color.purple.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(height: 120)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 40))
                    .foregroundColor(achievement.isUnlocked ? .purple : .gray.opacity(0.3))
            }
            
            Text(achievement.name)
                .font(.subheadline)
                .fontWeight(.medium)
            
            if !achievement.isUnlocked {
                Text("Locked")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

