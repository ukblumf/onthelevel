import SwiftUI

struct MenuView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("On The Level")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Keep your phone level!")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 20) {
                NavigationLink(destination: GameView(settings: settingsViewModel.gameSettings)) {
                    MenuButton(title: "Play", icon: "play.fill", color: .green)
                }
                
                NavigationLink(destination: ChallengeListView().environmentObject(settingsViewModel)) {
                    MenuButton(title: "Challenges", icon: "target", color: .purple)
                }
                
                Button(action: { showingSettings = true }) {
                    MenuButton(title: "Settings", icon: "gear", color: .blue)
                }
                
                NavigationLink(destination: HowToPlayView()) {
                    MenuButton(title: "How to Play", icon: "questionmark.circle", color: .orange)
                }
            }
            
            Spacer()
            
            VStack {
                Text("Difficulty: \(settingsViewModel.gameSettings.difficulty.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Duration: \(Int(settingsViewModel.gameSettings.gameDuration))s")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(settingsViewModel)
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
            
            Text(title)
                .font(.title2)
                .fontWeight(.medium)
            
            Spacer()
        }
        .foregroundColor(.white)
        .padding()
        .background(color)
        .cornerRadius(12)
        .frame(maxWidth: 300)
    }
}

struct HowToPlayView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("How to Play")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                InstructionCard(
                    icon: "iphone",
                    title: "Hold Your Phone",
                    description: "Hold your iPhone flat and level, like a spirit level."
                )
                
                InstructionCard(
                    icon: "timer",
                    title: "Beat the Clock",
                    description: "Keep your phone level for the entire duration (default 20 seconds)."
                )
                
                InstructionCard(
                    icon: "paintpalette.fill",
                    title: "Watch the Colors",
                    description: "Green = perfectly level. Red = tilted. Stay green!"
                )
                
                InstructionCard(
                    icon: "target",
                    title: "Lower Score Wins",
                    description: "Your score increases with every degree of tilt. Aim for 0!"
                )
                
                InstructionCard(
                    icon: "slider.horizontal.3",
                    title: "Choose Difficulty",
                    description: "Easy to Insane - higher difficulty is more sensitive to tilt."
                )
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InstructionCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        MenuView()
            .environmentObject(SettingsViewModel())
    }
}