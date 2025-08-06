import SwiftUI

struct ChallengeListView: View {
    @StateObject private var challengeService = ChallengeService()
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var selectedCategory: ChallengeCategory? = nil
    @State private var selectedDifficulty: ChallengeDifficulty? = nil
    
    private var filteredChallenges: [Challenge] {
        let challenges = challengeService.getChallenges(for: selectedCategory, difficulty: selectedDifficulty)
        return challenges.sorted { lhs, rhs in
            // First sort by difficulty level
            let difficultyOrder: [ChallengeDifficulty] = [.beginner, .intermediate, .advanced, .expert]
            let lhsIndex = difficultyOrder.firstIndex(of: lhs.difficulty) ?? 0
            let rhsIndex = difficultyOrder.firstIndex(of: rhs.difficulty) ?? 0
            
            if lhsIndex != rhsIndex {
                return lhsIndex < rhsIndex
            }
            
            // Then sort by category within the same difficulty
            return lhs.category.rawValue < rhs.category.rawValue
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                
                filterSection
                
                challengeGrid
            }
            .padding()
        }
        .navigationTitle("Challenges")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("Physical Challenges")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Balance your phone while performing physical activities")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var filterSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Filter by:")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button("Clear All") {
                    selectedCategory = nil
                    selectedDifficulty = nil
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(ChallengeCategory.allCases) { category in
                        FilterChip(
                            title: category.rawValue,
                            icon: category.iconName,
                            isSelected: selectedCategory == category,
                            color: category.color
                        ) {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                    
                    Divider()
                        .frame(height: 30)
                    
                    ForEach(ChallengeDifficulty.allCases) { difficulty in
                        FilterChip(
                            title: difficulty.rawValue,
                            icon: "star.fill",
                            isSelected: selectedDifficulty == difficulty,
                            color: difficulty.color
                        ) {
                            selectedDifficulty = selectedDifficulty == difficulty ? nil : difficulty
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var challengeGrid: some View {
        VStack(spacing: 20) {
            // Group challenges by difficulty level
            let groupedChallenges = Dictionary(grouping: filteredChallenges) { $0.difficulty }
            let sortedDifficulties: [ChallengeDifficulty] = [.beginner, .intermediate, .advanced, .expert]
            
            ForEach(sortedDifficulties, id: \.self) { difficulty in
                if let challengesForDifficulty = groupedChallenges[difficulty], !challengesForDifficulty.isEmpty {
                    VStack(spacing: 15) {
                        // Difficulty section header
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                    .font(.title3)
                                    .foregroundColor(difficulty.color)
                                
                                Text(difficulty.rawValue)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(difficulty.color)
                            }
                            
                            Spacer()
                            
                            Text("\(challengesForDifficulty.count) challenge\(challengesForDifficulty.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        // Grid for this difficulty level
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 15),
                            GridItem(.flexible(), spacing: 15)
                        ], spacing: 15) {
                            ForEach(challengesForDifficulty.sorted { $0.category.rawValue < $1.category.rawValue }) { challenge in
                                if challenge.isUnlocked {
                                    NavigationLink(destination: ChallengeDetailView(challenge: challenge).environmentObject(settingsViewModel)) {
                                        ChallengeCard(
                                            challenge: challenge,
                                            bestResult: challengeService.getBestResult(for: challenge.id)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    LockedChallengeCard(challenge: challenge)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? color : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(15)
        }
    }
}

struct ChallengeCard: View {
    let challenge: Challenge
    let bestResult: ChallengeResult?
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 8) {
                Image(systemName: challenge.iconName)
                    .font(.system(size: 30))
                    .foregroundColor(challenge.category.color)
                
                Text(challenge.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            VStack(spacing: 4) {
                HStack {
                    DifficultyBadge(difficulty: challenge.difficulty)
                    
                    Spacer()
                    
                    Text("\(Int(challenge.estimatedDuration))s")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let bestResult = bestResult {
                    HStack {
                        Text("Best:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text(bestResult.displayScore)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        if bestResult.completed {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .frame(height: 140)
    }
}

struct LockedChallengeCard: View {
    let challenge: Challenge
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.gray)
                
                Text(challenge.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 4) {
                DifficultyBadge(difficulty: challenge.difficulty)
                
                Text("Complete more challenges to unlock")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(12)
        .frame(height: 140)
        .opacity(0.6)
    }
}

struct DifficultyBadge: View {
    let difficulty: ChallengeDifficulty
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(difficulty.color)
            .foregroundColor(.white)
            .cornerRadius(4)
    }
}

#Preview {
    NavigationView {
        ChallengeListView()
    }
}