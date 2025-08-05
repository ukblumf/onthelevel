import SwiftUI

struct ResultsView: View {
    let score: GameScore
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            header
            
            scoreDisplay
            
            performanceStats
            
            actionButtons
        }
        .padding()
        .background(backgroundGradient)
    }
    
    private var header: some View {
        VStack(spacing: 15) {
            Text("Game Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(score.grade)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(gradeColor)
        }
    }
    
    private var scoreDisplay: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Final Score")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(score.displayScore)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Text("degrees of tilt")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            if score.totalDeviationScore == 0 {
                VStack(spacing: 10) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow)
                    
                    Text("PERFECT SCORE!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
                .padding()
                .background(.white.opacity(0.1))
                .cornerRadius(15)
            }
        }
    }
    
    private var performanceStats: some View {
        VStack(spacing: 15) {
            StatRow(
                label: "Average Deviation",
                value: String(format: "%.2f°", score.averageDeviation),
                icon: "chart.line.uptrend.xyaxis"
            )
            
            StatRow(
                label: "Difficulty",
                value: score.difficulty.rawValue,
                icon: "slider.horizontal.3"
            )
            
            StatRow(
                label: "Duration",
                value: String(format: "%.1fs", score.gameDuration),
                icon: "timer"
            )
            
            StatRow(
                label: "Date",
                value: DateFormatter.shortDateTime.string(from: score.timestamp),
                icon: "calendar"
            )
        }
        .padding()
        .background(.white.opacity(0.1))
        .cornerRadius(15)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 15) {
            Button(action: onDismiss) {
                HStack {
                    Image(systemName: "arrow.left")
                    Text("Back to Menu")
                }
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.blue)
                .cornerRadius(12)
            }
            
            Button(action: shareScore) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Score")
                }
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.white.opacity(0.2))
                .cornerRadius(12)
            }
        }
    }
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [gradeColor.opacity(0.6), gradeColor.opacity(0.3)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var gradeColor: Color {
        switch score.totalDeviationScore {
        case 0..<10:
            return .green
        case 10..<50:
            return .blue
        case 50..<100:
            return .orange
        default:
            return .red
        }
    }
    
    private func shareScore() {
        let scoreText = """
        🎯 On The Level Score: \(score.displayScore)°
        📊 Grade: \(score.grade)
        ⚙️ Difficulty: \(score.difficulty.rawValue)
        ⏱️ Duration: \(String(format: "%.1f", score.gameDuration))s
        
        Can you beat my score?
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [scoreText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 30)
            
            Text(label)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

extension DateFormatter {
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    ResultsView(
        score: GameScore(
            totalDeviationScore: 25.4,
            gameDuration: 20.0,
            difficulty: .medium,
            timestamp: Date()
        )
    ) {
        // Preview dismiss action
    }
}