import Foundation

enum ChallengeDifficulty: String, CaseIterable, Identifiable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    
    var id: String { rawValue }
    
    var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "blue"
        case .advanced: return "orange"
        case .expert: return "red"
        }
    }
    
    var scoreMultiplier: Double {
        switch self {
        case .beginner: return 1.0
        case .intermediate: return 1.5
        case .advanced: return 2.0
        case .expert: return 3.0
        }
    }
}

enum ChallengeCategory: String, CaseIterable, Identifiable {
    case movement = "Movement"
    case balance = "Balance"
    case strength = "Strength"
    case coordination = "Coordination"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .movement: return "figure.walk"
        case .balance: return "figure.stand"
        case .strength: return "figure.strengthtraining.traditional"
        case .coordination: return "hand.raised.fingers.spread"
        }
    }
    
    var color: String {
        switch self {
        case .movement: return "blue"
        case .balance: return "green"
        case .strength: return "red"
        case .coordination: return "purple"
        }
    }
}

struct Challenge: Identifiable, Hashable {
    let id: String
    let title: String
    let instruction: String
    let description: String
    let iconName: String
    let difficulty: ChallengeDifficulty
    let estimatedDuration: TimeInterval
    let category: ChallengeCategory
    let isUnlocked: Bool
    
    init(
        id: String,
        title: String,
        instruction: String,
        description: String,
        iconName: String,
        difficulty: ChallengeDifficulty,
        estimatedDuration: TimeInterval = 20.0,
        category: ChallengeCategory,
        isUnlocked: Bool = true
    ) {
        self.id = id
        self.title = title
        self.instruction = instruction
        self.description = description
        self.iconName = iconName
        self.difficulty = difficulty
        self.estimatedDuration = estimatedDuration
        self.category = category
        self.isUnlocked = isUnlocked
    }
}

struct ChallengeResult: Identifiable {
    let id = UUID()
    let challengeId: String
    let score: Double
    let completed: Bool
    let timestamp: Date
    let difficulty: Difficulty
    let gameDuration: TimeInterval
    
    var displayScore: String {
        String(format: "%.2f", score)
    }
    
    var grade: String {
        let adjustedScore = score / difficulty.sensitivityMultiplier
        switch adjustedScore {
        case 0..<5:
            return "Perfect!"
        case 5..<15:
            return "Excellent"
        case 15..<30:
            return "Great"
        case 30..<50:
            return "Good"
        default:
            return "Keep Practicing"
        }
    }
}