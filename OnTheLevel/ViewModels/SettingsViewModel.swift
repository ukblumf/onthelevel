import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var gameSettings = GameSettings()
    
    func updateDifficulty(_ difficulty: Difficulty) {
        gameSettings.difficulty = difficulty
    }
    
    func updateGameDuration(_ duration: TimeInterval) {
        gameSettings.gameDuration = duration
    }
}