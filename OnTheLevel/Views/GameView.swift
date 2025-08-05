import SwiftUI
import UIKit

struct GameView: View {
    let settings: GameSettings
    @StateObject private var gameViewModel: GameViewModel
    @State private var showingResults = false
    @Environment(\.dismiss) private var dismiss
    
    init(settings: GameSettings) {
        self.settings = settings
        self._gameViewModel = StateObject(wrappedValue: GameViewModel(settings: settings))
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
                gameHeader
                
                Spacer()
                
                if !gameViewModel.isGameActive {
                    startGameSection
                } else {
                    gamePlaySection
                }
                
                Spacer()
                
                gameStats
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
            if score != nil && gameViewModel.gameCompletedNaturally {
                showingResults = true
            }
        }
        .sheet(isPresented: $showingResults) {
            if let score = gameViewModel.gameScore {
                ResultsView(score: score) {
                    showingResults = false
                    AppDelegate.orientationLock = .portrait
                    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                    windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                    dismiss()
                }
            }
        }
    }
    
    private var gameHeader: some View {
        VStack(spacing: 10) {
            Text("On The Level")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(settings.difficulty.rawValue)
                .font(.title2)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    private var startGameSection: some View {
        VStack(spacing: 30) {
            VStack(spacing: 15) {
                Image(systemName: "iphone")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("Hold your phone flat and level")
                    .font(.title2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Tap to start the \(Int(settings.gameDuration)) second challenge")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            Button(action: gameViewModel.startGame) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Game")
                }
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.green)
                .padding(.horizontal, 40)
                .padding(.vertical, 15)
                .background(.white)
                .cornerRadius(25)
            }
        }
    }
    
    private var gamePlaySection: some View {
        HStack(spacing: 40) {
            // Left side - Timer
            VStack(spacing: 15) {
                Text(gameViewModel.formattedTimeRemaining)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Text("seconds\nremaining")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .frame(width: 120)
            
            Spacer()
            
            // Center - Spirit Level
            VStack(spacing: 20) {
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
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 8) {
                    VStack(spacing: 3) {
                        Text("Left/Right")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("\(String(format: "%.1f", gameViewModel.pitchAngle))°")
                            .font(.system(size: 20, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 3) {
                        Text("Up/Down")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("\(String(format: "%.1f", gameViewModel.rollAngle))°")
                            .font(.system(size: 20, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(width: 120)
        }
        .padding(.horizontal, 20)
    }
    
    private var gameStats: some View {
        VStack(spacing: 8) {
            Text("Lower is better • 0 is perfect")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

struct LevelIndicator: View {
    let tilt: Double
    let rollAngle: Double
    let pitchAngle: Double
    let difficulty: Difficulty
    
    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(.white.opacity(0.2))
                    .frame(width: 250, height: 250)
                
                // Target circle in center
                Circle()
                    .stroke(.white.opacity(0.4), lineWidth: 2)
                    .frame(width: 16, height: 16)
                
                // Moving bubble
                Circle()
                    .fill(.white)
                    .frame(width: 16, height: 16)
                    .offset(x: offsetX, y: offsetY)
                    .animation(.easeInOut(duration: 0.1), value: rollAngle + pitchAngle)
            }
            
            Text(levelStatus)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
    
    private var offsetX: Double {
        let maxOffset: Double = 90
        let sensitivity: Double = 3.0
        let bubbleMovement = -pitchAngle * sensitivity
        return min(max(bubbleMovement, -maxOffset), maxOffset)
    }
    
    private var offsetY: Double {
        let maxOffset: Double = 90
        let sensitivity: Double = 2.0
        let bubbleMovement = rollAngle * sensitivity
        return min(max(bubbleMovement, -maxOffset), maxOffset)
    }
    
    private var levelStatus: String {
        if tilt < difficulty.maxDeviationForGreen * 0.2 {
            return "Perfect!"
        } else if tilt < difficulty.maxDeviationForGreen * 0.5 {
            return "Great"
        } else if tilt < difficulty.maxDeviationForGreen {
            return "Good"
        } else {
            return "Level it!"
        }
    }
}

#Preview {
    NavigationView {
        GameView(settings: GameSettings())
    }
}