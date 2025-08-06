import Foundation
import Combine

class ChallengeService: ObservableObject {
    @Published var challenges: [Challenge] = []
    @Published var challengeResults: [String: [ChallengeResult]] = [:]
    @Published var unlockedChallenges: Set<String> = []
    
    private let userDefaults = UserDefaults.standard
    private let challengeResultsKey = "challengeResults"
    private let unlockedChallengesKey = "unlockedChallenges"
    
    init() {
        setupChallenges()
        loadResults()
        loadUnlockedChallenges()
    }
    
    private func setupChallenges() {
        challenges = [
            // Movement Challenges
            Challenge(
                id: "walk_10_steps",
                title: "Walk 10 Steps",
                instruction: "Walk 10 steps while keeping the bubble centered",
                description: "Take slow, steady steps while maintaining perfect balance. Focus on smooth movement.",
                iconName: "figure.walk",
                difficulty: .beginner,
                estimatedDuration: 15.0,
                category: .movement
            ),
            
            Challenge(
                id: "turn_around",
                title: "Turn Around 360°",
                instruction: "Make a complete turn while staying level",
                description: "Slowly rotate in place while keeping the bubble in the center. Take your time.",
                iconName: "arrow.clockwise",
                difficulty: .intermediate,
                estimatedDuration: 20.0,
                category: .movement
            ),
            
            Challenge(
                id: "walk_circle",
                title: "Walk in Circle",
                instruction: "Walk in a small circle while staying balanced",
                description: "Walk in a tight circle, maintaining level throughout the curved path.",
                iconName: "circle.dotted",
                difficulty: .advanced,
                estimatedDuration: 25.0,
                category: .movement
            ),
            
            // Balance Challenges
            Challenge(
                id: "one_foot",
                title: "Stand on One Foot",
                instruction: "Balance on one foot while holding level",
                description: "Lift one foot and maintain your balance. Use your core for stability.",
                iconName: "figure.stand.line.dotted.figure.stand",
                difficulty: .intermediate,
                estimatedDuration: 20.0,
                category: .balance
            ),
            
            Challenge(
                id: "eyes_closed",
                title: "Close Your Eyes",
                instruction: "Keep level with eyes closed",
                description: "Close your eyes and rely on your inner balance. Trust your body's natural balance.",
                iconName: "eye.slash",
                difficulty: .advanced,
                estimatedDuration: 15.0,
                category: .balance
            ),
            
            Challenge(
                id: "tiptoe_balance",
                title: "Tiptoe Balance",
                instruction: "Balance on your tiptoes while staying level",
                description: "Rise up on your toes and maintain balance. Engage your calf muscles.",
                iconName: "figure.walk.motion",
                difficulty: .expert,
                estimatedDuration: 20.0,
                category: .balance
            ),
            
            // Strength Challenges
            Challenge(
                id: "squat_hold",
                title: "Squat Hold",
                instruction: "Hold a squat position while keeping level",
                description: "Lower into a squat and hold the position. Keep your back straight and core engaged.",
                iconName: "figure.squat",
                difficulty: .intermediate,
                estimatedDuration: 15.0,
                category: .strength
            ),
            
            Challenge(
                id: "extended_arms",
                title: "Extended Arms",
                instruction: "Hold phone with arms fully extended",
                description: "Extend your arms straight out and hold the phone steady. Use shoulder stability.",
                iconName: "figure.arms.open",
                difficulty: .advanced,
                estimatedDuration: 20.0,
                category: .strength
            ),
            
            Challenge(
                id: "wall_pushup",
                title: "Wall Push-up",
                instruction: "Do slow push-ups against the wall",
                description: "Place one hand on wall, hold phone with other. Do slow push-ups while staying level.",
                iconName: "figure.strengthtraining.traditional",
                difficulty: .expert,
                estimatedDuration: 25.0,
                category: .strength
            ),
            
            // Coordination Challenges
            Challenge(
                id: "left_hand_only",
                title: "Left Hand Only",
                instruction: "Hold phone with left hand only",
                description: "Use only your non-dominant hand (or left hand) to hold the device steady.",
                iconName: "hand.raised.fill",
                difficulty: .beginner,
                estimatedDuration: 20.0,
                category: .coordination
            ),
            
            Challenge(
                id: "right_hand_only",
                title: "Right Hand Only",
                instruction: "Hold phone with right hand only",
                description: "Use only your dominant hand (or right hand) to maintain perfect balance.",
                iconName: "hand.raised",
                difficulty: .beginner,
                estimatedDuration: 20.0,
                category: .coordination
            ),
            
            Challenge(
                id: "switch_hands",
                title: "Switch Hands",
                instruction: "Switch hands halfway through the timer",
                description: "Start with one hand, then smoothly transfer to the other hand mid-game.",
                iconName: "arrow.left.arrow.right",
                difficulty: .advanced,
                estimatedDuration: 30.0,
                category: .coordination
            )
        ]
        
        // Initially unlock beginner challenges
        unlockedChallenges = Set(challenges.filter { $0.difficulty == .beginner }.map { $0.id })
    }
    
    func getChallenges(for category: ChallengeCategory? = nil, difficulty: ChallengeDifficulty? = nil) -> [Challenge] {
        var filteredChallenges = challenges
        
        if let category = category {
            filteredChallenges = filteredChallenges.filter { $0.category == category }
        }
        
        if let difficulty = difficulty {
            filteredChallenges = filteredChallenges.filter { $0.difficulty == difficulty }
        }
        
        return filteredChallenges.map { challenge in
            Challenge(
                id: challenge.id,
                title: challenge.title,
                instruction: challenge.instruction,
                description: challenge.description,
                iconName: challenge.iconName,
                difficulty: challenge.difficulty,
                estimatedDuration: challenge.estimatedDuration,
                category: challenge.category,
                isUnlocked: unlockedChallenges.contains(challenge.id)
            )
        }
    }
    
    func getChallenge(by id: String) -> Challenge? {
        return challenges.first { $0.id == id }
    }
    
    func saveResult(_ result: ChallengeResult) {
        if challengeResults[result.challengeId] == nil {
            challengeResults[result.challengeId] = []
        }
        challengeResults[result.challengeId]?.append(result)
        
        // Check for unlocking new challenges
        checkAndUnlockChallenges(for: result.challengeId)
        
        saveResults()
    }
    
    func getBestResult(for challengeId: String) -> ChallengeResult? {
        guard let results = challengeResults[challengeId] else { return nil }
        return results.min(by: { $0.score < $1.score })
    }
    
    func getCompletedChallenges() -> [String] {
        return challengeResults.compactMap { (challengeId, results) in
            results.contains { $0.completed } ? challengeId : nil
        }
    }
    
    private func checkAndUnlockChallenges(for completedChallengeId: String) {
        let completedChallenges = getCompletedChallenges()
        
        // Unlock intermediate challenges after completing 2 beginner challenges
        let beginnerChallenges = challenges.filter { $0.difficulty == .beginner }
        let completedBeginners = beginnerChallenges.filter { completedChallenges.contains($0.id) }
        
        if completedBeginners.count >= 2 {
            let intermediateChallenges = challenges.filter { $0.difficulty == .intermediate }
            intermediateChallenges.forEach { unlockedChallenges.insert($0.id) }
        }
        
        // Unlock advanced challenges after completing 3 intermediate challenges
        let intermediateChallenges = challenges.filter { $0.difficulty == .intermediate }
        let completedIntermediates = intermediateChallenges.filter { completedChallenges.contains($0.id) }
        
        if completedIntermediates.count >= 3 {
            let advancedChallenges = challenges.filter { $0.difficulty == .advanced }
            advancedChallenges.forEach { unlockedChallenges.insert($0.id) }
        }
        
        // Unlock expert challenges after completing 2 advanced challenges
        let advancedChallenges = challenges.filter { $0.difficulty == .advanced }
        let completedAdvanced = advancedChallenges.filter { completedChallenges.contains($0.id) }
        
        if completedAdvanced.count >= 2 {
            let expertChallenges = challenges.filter { $0.difficulty == .expert }
            expertChallenges.forEach { unlockedChallenges.insert($0.id) }
        }
        
        saveUnlockedChallenges()
    }
    
    private func saveResults() {
        if let encoded = try? JSONEncoder().encode(challengeResults) {
            userDefaults.set(encoded, forKey: challengeResultsKey)
        }
    }
    
    private func loadResults() {
        if let data = userDefaults.data(forKey: challengeResultsKey),
           let decoded = try? JSONDecoder().decode([String: [ChallengeResult]].self, from: data) {
            challengeResults = decoded
        }
    }
    
    private func saveUnlockedChallenges() {
        let array = Array(unlockedChallenges)
        userDefaults.set(array, forKey: unlockedChallengesKey)
    }
    
    private func loadUnlockedChallenges() {
        if let saved = userDefaults.array(forKey: unlockedChallengesKey) as? [String] {
            unlockedChallenges = Set(saved)
        } else {
            // Default: unlock beginner challenges
            unlockedChallenges = Set(challenges.filter { $0.difficulty == .beginner }.map { $0.id })
        }
    }
}

