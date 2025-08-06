import SwiftUI
import UIKit

struct ChallengeGameView: View {
    let challenge: Challenge
    let settings: GameSettings
    @StateObject private var gameViewModel: GameViewModel
    @StateObject private var challengeService = ChallengeService()
    @State private var showingResults = false
    @State private var challengeResult: ChallengeResult?
    @Environment(\.dismiss) private var dismiss
    
    init(challenge: Challenge, settings: GameSettings) {
        self.challenge = challenge
        self.settings = settings
        self._gameViewModel = StateObject(wrappedValue: GameViewModel(settings: GameSettings(
            difficulty: settings.difficulty,
            gameDuration: challenge.estimatedDuration
        )))
    }
    
    var body: some View {
        ZStack {
            ColorUtils.backgroundGradient(
                for: gameViewModel.currentTilt,
                difficulty: settings.difficulty
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.1), value: gameViewModel.currentTilt)
            
            VStack {
                challengeHeader
                
                Spacer()
                
                if !gameViewModel.isGameActive {
                    startChallengeSection
                } else {
                    challengePlaySection
                }
                
                Spacer()
                
                challengeStats
            }
            .padding()
        }
        .navigationBarBackButtonHidden(gameViewModel.isGameActive)
        .onAppear {
            AppDelegate.orientationLock = .landscape
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
        }
        .onDisappear {
            AppDelegate.orientationLock = .portrait
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        }
        .toolbar {
            if gameViewModel.isGameActive {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Quit") {
                        gameViewModel.quitGame()
                        AppDelegate.orientationLock = .portrait
                        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                        windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                }
            }
        }
        .onChange(of: gameViewModel.gameScore) { score in
            if let score = score, gameViewModel.gameCompletedNaturally {
                createChallengeResult(from: score)
                showingResults = true
            }
        }
        .sheet(isPresented: $showingResults) {
            if let result = challengeResult {
                ChallengeResultsView(challenge: challenge, result: result) {
                    showingResults = false
                    AppDelegate.orientationLock = .portrait
                    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                    windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                    dismiss()
                }
            }
        }
    }
    
    private var challengeHeader: some View {
        VStack(spacing: 10) {
            Text(challenge.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack {
                DifficultyBadge(difficulty: challenge.difficulty)
                    .scaleEffect(0.9)
                
                Text("•")
                    .foregroundColor(.white.opacity(0.6))
                
                Text(settings.difficulty.rawValue + " Mode")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    private var startChallengeSection: some View {
        VStack(spacing: 30) {
            VStack(spacing: 20) {
                Image(systemName: challenge.iconName)
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                
                VStack(spacing: 10) {
                    Text(challenge.instruction)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(challenge.description)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            .padding()
            .background(.white.opacity(0.1))
            .cornerRadius(15)
            
            Button(action: gameViewModel.startGame) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Challenge")
                }
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color(challenge.category.color))
                .padding(.horizontal, 40)
                .padding(.vertical, 15)
                .background(.white)
                .cornerRadius(25)
            }
        }
    }
    
    private var challengePlaySection: some View {
        HStack(spacing: 30) {
            // Left side - Timer
            VStack(spacing: 15) {
                Text(gameViewModel.formattedTimeRemaining)
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Text("seconds\nremaining")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .frame(width: 100)
            
            Spacer()
            
            // Center - Challenge Instruction + Spirit Level
            VStack(spacing: 25) {
                // Challenge instruction with icon
                VStack(spacing: 10) {
                    Image(systemName: challenge.iconName)
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(.white.opacity(0.1))
                                .frame(width: 50, height: 50)
                        )
                    
                    Text(challenge.instruction)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .padding()
                .background(.white.opacity(0.1))
                .cornerRadius(15)
                
                // Spirit Level
                LevelIndicator(
                    tilt: gameViewModel.currentTilt,
                    rollAngle: gameViewModel.rollAngle,
                    pitchAngle: gameViewModel.pitchAngle,
                    difficulty: settings.difficulty
                )
            }
            
            Spacer()
            
            // Right side - Score and Tilt
            VStack(spacing: 15) {
                VStack(spacing: 5) {
                    Text("Score")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(gameViewModel.formattedCurrentScore)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 8) {
                    VStack(spacing: 3) {
                        Text("L/R")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("\(String(format: "%.1f", gameViewModel.pitchAngle))°")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 3) {
                        Text("U/D")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("\(String(format: "%.1f", gameViewModel.rollAngle))°")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(width: 100)
        }
        .padding(.horizontal, 20)
    }
    
    private var challengeStats: some View {
        VStack(spacing: 8) {
            Text("Challenge: \(challenge.title)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text("Lower score is better • 0 is perfect")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    private func createChallengeResult(from gameScore: GameScore) {
        let bonusMultiplier = challenge.difficulty.scoreMultiplier
        let finalScore = gameScore.totalDeviationScore / bonusMultiplier
        
        challengeResult = ChallengeResult(
            challengeId: challenge.id,
            score: finalScore,
            completed: finalScore < 100.0, // Arbitrary completion threshold
            timestamp: Date(),
            difficulty: gameScore.difficulty,
            gameDuration: gameScore.gameDuration
        )
        
        if let result = challengeResult {
            challengeService.saveResult(result)
        }
    }
}

struct ChallengeResultsView: View {
    let challenge: Challenge
    let result: ChallengeResult
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            // Challenge completion header
            VStack(spacing: 15) {
                Image(systemName: result.completed ? "trophy.fill" : challenge.iconName)
                    .font(.system(size: 60))
                    .foregroundColor(result.completed ? .yellow : Color(challenge.category.color))
                
                Text(result.completed ? "Challenge Complete!" : "Challenge Attempted")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(result.completed ? .green : .primary)
                
                Text(challenge.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            // Score display
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Your Score")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(result.displayScore)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    Text(result.grade)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(result.completed ? .green : .blue)
                }
                
                if result.completed {
                    VStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.green)
                        
                        Text("Excellent work! You've mastered this challenge.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            // Performance stats
            HStack(spacing: 20) {
                StatCard(
                    title: "Difficulty",
                    value: challenge.difficulty.rawValue,
                    subtitle: "",
                    icon: "star.fill",
                    color: Color(challenge.difficulty.color)
                )
                
                StatCard(
                    title: "Duration",
                    value: String(format: "%.1fs", result.gameDuration),
                    subtitle: "",
                    icon: "timer",
                    color: .blue
                )
                
                StatCard(
                    title: "Category",
                    value: challenge.category.rawValue,
                    subtitle: "",
                    icon: challenge.category.iconName,
                    color: Color(challenge.category.color)
                )
            }
            
            // Action buttons
            VStack(spacing: 15) {
                Button(action: onDismiss) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back to Challenges")
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(challenge.category.color))
                    .cornerRadius(12)
                }
                
                Button(action: shareResult) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Achievement")
                    }
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(challenge.category.color).opacity(0.1),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private func shareResult() {
        let statusEmoji = result.completed ? "🏆" : "🎯"
        let shareText = """
        \(statusEmoji) Just completed the \(challenge.title) challenge in On The Level!
        
        📊 Score: \(result.displayScore)°
        ⭐ Grade: \(result.grade)
        🎯 Challenge: \(challenge.category.rawValue) • \(challenge.difficulty.rawValue)
        
        Can you beat my score?
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

#Preview {
    NavigationView {
        ChallengeGameView(
            challenge: Challenge(
                id: "walk_10_steps",
                title: "Walk 10 Steps",
                instruction: "Walk 10 steps while keeping the bubble centered",
                description: "Take slow, steady steps while maintaining perfect balance.",
                iconName: "figure.walk",
                difficulty: .beginner,
                estimatedDuration: 15.0,
                category: .movement
            ),
            settings: GameSettings()
        )
    }
}