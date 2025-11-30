import SwiftUI
import Combine

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    StatCard(title: "Check-In Streak", value: "\(viewModel.streak) day\(viewModel.streak == 1 ? "" : "s")", icon: "flame.fill", color: .orange)
                    
                    StatCard(title: "Total Check-Ins", value: "\(viewModel.totalCheckIns)", icon: "checkmark.circle.fill", color: .green)
                    
                    StatCard(title: "Most Common Emotion", value: viewModel.mostCommonEmotion ?? "N/A", icon: "heart.fill", color: .blue)
                    
                    StatCard(title: "Favorite Activity", value: viewModel.favoriteActivity ?? "N/A", icon: "leaf.fill", color: .mint)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekly Overview")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        WeeklyChart(data: viewModel.weeklyData)
                            .frame(height: 200)
                            .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
            .onAppear {
                viewModel.loadStatistics()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CheckInSaved"))) { _ in
                viewModel.loadStatistics()
            }
        }
    }
}

class StatisticsViewModel: ObservableObject {
    @Published var streak = 0
    @Published var totalCheckIns = 0
    @Published var mostCommonEmotion: String?
    @Published var favoriteActivity: String?
    @Published var weeklyData: [Int] = []
    
    private let checkInService = CheckInService.shared
    
    func loadStatistics() {
        streak = checkInService.getCurrentStreak()
        totalCheckIns = checkInService.getAllCheckIns().count
        mostCommonEmotion = checkInService.getMostCommonEmotion()
        favoriteActivity = checkInService.getFavoriteActivity()
        weeklyData = checkInService.getWeeklyCheckIns()
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 50)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct WeeklyChart: View {
    let data: [Int]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(0..<7) { index in
                VStack {
                    let height = max(20, CGFloat(data[safe: index] ?? 0) * 30)
                    Rectangle()
                        .fill(Color.purple.opacity(0.7))
                        .frame(width: 30, height: height)
                        .cornerRadius(4)
                    
                    Text(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][index])
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

