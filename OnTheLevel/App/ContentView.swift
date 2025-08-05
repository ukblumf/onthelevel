import SwiftUI

struct ContentView: View {
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            MenuView()
                .environmentObject(settingsViewModel)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ContentView()
}