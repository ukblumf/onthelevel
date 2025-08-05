import Foundation
import Combine
import SwiftUI

class GameViewModel: ObservableObject {
    @Published var isGameActive = false
    @Published var timeRemaining: TimeInterval = 0
    @Published var currentScore: Double = 0
    @Published var gameScore: GameScore?
    @Published var gameCompletedNaturally = false
    
    private let motionService = MotionService()
    private var gameTimer: Timer?
    private var scoreTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var gameSettings: GameSettings
    private var gameStartTime: Date?
    
    init(settings: GameSettings) {
        self.gameSettings = settings
        self.timeRemaining = settings.gameDuration
        setupMotionTracking()
    }
    
    private func setupMotionTracking() {
        motionService.tiltPublisher
            .sink { [weak self] tilt in
                guard let self = self, self.isGameActive else { return }
                let adjustedTilt = tilt * self.gameSettings.difficulty.sensitivityMultiplier
                self.currentScore += adjustedTilt / 60.0
            }
            .store(in: &cancellables)
    }
    
    func startGame() {
        guard !isGameActive else { return }
        
        isGameActive = true
        currentScore = 0
        timeRemaining = gameSettings.gameDuration
        gameStartTime = Date()
        gameScore = nil
        gameCompletedNaturally = false
        
        motionService.startMotionUpdates()
        startGameTimer()
        startScoreTracking()
    }
    
    func stopGame() {
        stopGame(completedNaturally: true)
    }
    
    func quitGame() {
        stopGame(completedNaturally: false)
    }
    
    private func stopGame(completedNaturally: Bool) {
        isGameActive = false
        motionService.stopMotionUpdates()
        gameTimer?.invalidate()
        scoreTimer?.invalidate()
        
        gameCompletedNaturally = completedNaturally
        
        if completedNaturally, let startTime = gameStartTime {
            let actualDuration = Date().timeIntervalSince(startTime)
            gameScore = GameScore(
                totalDeviationScore: currentScore,
                gameDuration: actualDuration,
                difficulty: gameSettings.difficulty,
                timestamp: Date()
            )
        }
    }
    
    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.timeRemaining -= 0.1
            
            if self.timeRemaining <= 0 {
                self.timeRemaining = 0
                self.stopGame()
            }
        }
    }
    
    private func startScoreTracking() {
        scoreTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isGameActive else { return }
        }
    }
    
    var currentTilt: Double {
        motionService.currentTilt
    }
    
    var rollAngle: Double {
        motionService.rollAngle
    }
    
    var pitchAngle: Double {
        motionService.pitchAngle
    }
    
    var formattedTimeRemaining: String {
        String(format: "%.1f", timeRemaining)
    }
    
    var formattedCurrentScore: String {
        String(format: "%.1f", currentScore)
    }
}