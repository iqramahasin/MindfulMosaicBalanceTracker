import Foundation
import SwiftUI

struct CheckInData: Codable, Identifiable {
    let id: UUID
    let date: Date
    let emotion: String
    let activities: [String]
    let note: String
    
    init(id: UUID = UUID(), date: Date = Date(), emotion: String, activities: [String], note: String) {
        self.id = id
        self.date = date
        self.emotion = emotion
        self.activities = activities
        self.note = note
    }
}

struct MosaicTileData {
    let color: Color
    let shape: MosaicTileShape
    let emotion: String
    let activity: String?
}

enum MosaicTileShape {
    case circle
    case square
    case hexagon
}

extension MosaicTileShape {
    static func fromActivity(_ activity: String) -> MosaicTileShape {
        switch activity.lowercased() {
        case "exercise", "walk":
            return .hexagon
        case "meditation":
            return .circle
        default:
            return .square
        }
    }
}

extension Color {
    static func fromEmotion(_ emotion: String) -> Color {
        switch emotion.lowercased() {
        case "joy", "excitement", "gratitude":
            return .yellow
        case "calm", "inspiration":
            return .blue
        case "anxiety", "confusion":
            return .gray
        case "pride":
            return .orange
        case "tiredness":
            return .brown
        case "sadness":
            return .purple
        default:
            return .cyan
        }
    }
}

