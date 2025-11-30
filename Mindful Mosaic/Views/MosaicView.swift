import SwiftUI
import Combine

struct MosaicView: View {
    @StateObject private var viewModel = MosaicViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Your Mindful Mosaic")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        MosaicCanvas(tiles: viewModel.tiles)
                            .frame(height: 400)
                            .padding()
                        
                        Text("Your journey visualized")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            .navigationTitle("Mosaic")
            .onAppear {
                viewModel.loadTiles()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CheckInSaved"))) { _ in
                viewModel.loadTiles()
            }
        }
    }
}

class MosaicViewModel: ObservableObject {
    @Published var tiles: [MosaicTileData] = []
    private let checkInService = CheckInService.shared
    
    func loadTiles() {
        let checkIns = checkInService.getAllCheckIns().suffix(30)
        tiles = checkIns.flatMap { checkIn -> [MosaicTileData] in
            let color = Color.fromEmotion(checkIn.emotion)
            if checkIn.activities.isEmpty {
                return [MosaicTileData(color: color, shape: .square, emotion: checkIn.emotion, activity: nil)]
            } else {
                return checkIn.activities.map { activity in
                    MosaicTileData(color: color, shape: MosaicTileShape.fromActivity(activity), emotion: checkIn.emotion, activity: activity)
                }
            }
        }
    }
}

struct MosaicCanvas: View {
    let tiles: [MosaicTileData]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.2))
                    .background(.ultraThinMaterial)
                
                if tiles.isEmpty {
                    Text("Start your journey with a check-in")
                        .foregroundColor(.secondary)
                        .font(.headline)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50), spacing: 10)], spacing: 10) {
                            ForEach(Array(tiles.enumerated()), id: \.offset) { index, tile in
                                MosaicTile(color: tile.color, shape: tile.shape)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }
}

struct MosaicTile: View {
    let color: Color
    let shape: MosaicTileShape
    
    var body: some View {
        Group {
            switch shape {
            case .circle:
                Circle()
                    .fill(color.opacity(0.7))
                    .frame(width: 50, height: 50)
            case .square:
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.7))
                    .frame(width: 50, height: 50)
            case .hexagon:
                HexagonShape()
                    .fill(color.opacity(0.7))
                    .frame(width: 50, height: 50)
            }
        }
    }
}

struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        for i in 0..<6 {
            let angle = CGFloat.pi / 3 * CGFloat(i) - CGFloat.pi / 2
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

