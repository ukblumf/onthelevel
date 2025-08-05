import Foundation

struct GameScore: Equatable {
    let totalDeviationScore: Double
    let gameDuration: TimeInterval
    let difficulty: Difficulty
    let timestamp: Date
    
    var averageDeviation: Double {
        totalDeviationScore / gameDuration
    }
    
    var displayScore: String {
        String(format: "%.2f", totalDeviationScore)
    }
    
    var grade: String {
        switch totalDeviationScore {
        case 0..<10:
            return "Perfect!"
        case 10..<50:
            return "Excellent"
        case 50..<100:
            return "Good"
        case 100..<200:
            return "Fair"
        default:
            return "Keep Practicing"
        }
    }
}