import SwiftUI

struct ChallengeDetailView: View {
    let challenge: Challenge
    @StateObject private var challengeService = ChallengeService()
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var showingInstructions = false
    
    private var bestResult: ChallengeResult? {
        challengeService.getBestResult(for: challenge.id)
    }
    
    private var allResults: [ChallengeResult] {
        challengeService.challengeResults[challenge.id] ?? []
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                challengeHeader
                
                instructionSection
                
                statisticsSection
                
                startChallengeSection
                
                if !allResults.isEmpty {
                    previousAttemptsSection
                }
            }
            .padding()
        }
        .navigationTitle(challenge.title)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingInstructions) {
            ChallengeInstructionsView(challenge: challenge)
        }
    }
    
    private var challengeHeader: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color(challenge.category.color).opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: challenge.iconName)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(Color(challenge.category.color))
            }
            
            VStack(spacing: 8) {
                Text(challenge.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 15) {
                    DifficultyBadge(difficulty: challenge.difficulty)
                    
                    HStack(spacing: 4) {
                        Image(systemName: challenge.category.iconName)
                            .font(.caption)
                        
                        Text(challenge.category.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        
                        Text("\(Int(challenge.estimatedDuration))s")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var instructionSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Instructions")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View Details") {
                    showingInstructions = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(challenge.instruction)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(challenge.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var statisticsSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Your Performance")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                StatCard(
                    title: "Best Score",
                    value: bestResult?.displayScore ?? "—",
                    subtitle: bestResult?.grade ?? "",
                    icon: "trophy.fill",
                    color: .yellow
                )
                
                StatCard(
                    title: "Attempts",
                    value: "\(allResults.count)",
                    subtitle: allResults.isEmpty ? "" : "tries",
                    icon: "flag.checkered",
                    color: .blue
                )
                
                StatCard(
                    title: "Completed",
                    value: allResults.contains { $0.completed } ? "Yes" : "No",
                    subtitle: allResults.contains { $0.completed } ? "✓" : "",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
        }
    }
    
    private var startChallengeSection: some View {
        VStack(spacing: 15) {
            NavigationLink(
                destination: ChallengeGameView(
                    challenge: challenge,
                    settings: settingsViewModel.gameSettings
                )
            ) {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.title2)
                    
                    Text("Start Challenge")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(challenge.category.color))
                .cornerRadius(12)
            }
            
            Text("Uses current difficulty: \(settingsViewModel.gameSettings.difficulty.rawValue)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var previousAttemptsSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Previous Attempts")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(allResults.count) total")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 8) {
                ForEach(allResults.prefix(5).reversed(), id: \.id) { result in
                    AttemptRow(result: result)
                }
                
                if allResults.count > 5 {
                    Text("... and \(allResults.count - 5) more attempts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 5)
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct AttemptRow: View {
    let result: ChallengeResult
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: result.timestamp, relativeTo: Date())
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Score: \(result.displayScore)")
                        .font(.body)
                        .fontWeight(.medium)
                    
                    if result.completed {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Text(timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(result.grade)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                
                Text(result.difficulty.rawValue)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ChallengeInstructionsView: View {
    let challenge: Challenge
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: challenge.iconName)
                        .font(.system(size: 60))
                        .foregroundColor(Color(challenge.category.color))
                        .padding()
                    
                    VStack(spacing: 15) {
                        Text(challenge.instruction)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        
                        Text(challenge.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    VStack(spacing: 10) {
                        Text("Tips for Success")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            TipRow(text: "Take your time and move slowly")
                            TipRow(text: "Focus on keeping the bubble centered")
                            TipRow(text: "Use your core muscles for stability")
                            TipRow(text: "Practice the movement before starting")
                            TipRow(text: "Stay relaxed and breathe normally")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Challenge Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TipRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .font(.caption)
                .foregroundColor(.yellow)
                .frame(width: 16)
            
            Text(text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        ChallengeDetailView(
            challenge: Challenge(
                id: "walk_10_steps",
                title: "Walk 10 Steps",
                instruction: "Walk 10 steps while keeping the bubble centered",
                description: "Take slow, steady steps while maintaining perfect balance. Focus on smooth movement.",
                iconName: "figure.walk",
                difficulty: .beginner,
                estimatedDuration: 15.0,
                category: .movement
            )
        )
        .environmentObject(SettingsViewModel())
    }
}