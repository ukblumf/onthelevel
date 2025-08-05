import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Timer") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Game Duration")
                            .font(.headline)
                        
                        HStack {
                            Text("\(Int(settingsViewModel.gameSettings.gameDuration)) seconds")
                                .font(.title3)
                                .fontWeight(.medium)
                            
                            Spacer()
                        }
                        
                        Slider(
                            value: $settingsViewModel.gameSettings.gameDuration,
                            in: 10...60,
                            step: 5
                        ) {
                            Text("Duration")
                        } minimumValueLabel: {
                            Text("10s")
                                .font(.caption)
                        } maximumValueLabel: {
                            Text("60s")
                                .font(.caption)
                        }
                    }
                }
                
                Section("Difficulty") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Difficulty")
                            .font(.headline)
                        
                        Picker("Difficulty", selection: $settingsViewModel.gameSettings.difficulty) {
                            ForEach(Difficulty.allCases, id: \.self) { difficulty in
                                Text(difficulty.rawValue)
                                    .tag(difficulty)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 120)
                    }
                }
                
                Section("Difficulty Guide") {
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        DifficultyRow(difficulty: difficulty)
                    }
                }
            }
            .navigationTitle("Settings")
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
    
    private func difficultyDescription(_ difficulty: Difficulty) -> String {
        switch difficulty {
        case .easy:
            return "Forgiving - up to 10° tilt stays green"
        case .medium:
            return "Balanced - up to 5° tilt stays green"
        case .hard:
            return "Challenging - up to 2° tilt stays green"
        case .insane:
            return "Extreme - only 1° tilt stays green"
        }
    }
}

struct DifficultyRow: View {
    let difficulty: Difficulty
    
    var body: some View {
        HStack {
            Circle()
                .fill(difficultyColor)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(difficulty.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Max green tilt: \(String(format: "%.0f", difficulty.maxDeviationForGreen))°")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private var difficultyColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .orange
        case .insane: return .red
        }
    }
}


#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
}