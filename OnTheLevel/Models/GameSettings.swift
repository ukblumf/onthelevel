import Foundation

enum Difficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case insane = "Insane"
    
    var sensitivityMultiplier: Double {
        switch self {
        case .easy: return 0.5
        case .medium: return 1.0
        case .hard: return 2.0
        case .insane: return 4.0
        }
    }
    
    var maxDeviationForGreen: Double {
        switch self {
        case .easy: return 10.0
        case .medium: return 5.0
        case .hard: return 2.0
        case .insane: return 1.0
        }
    }
}

struct GameSettings {
    var difficulty: Difficulty = .medium
    var gameDuration: TimeInterval = 20.0
}