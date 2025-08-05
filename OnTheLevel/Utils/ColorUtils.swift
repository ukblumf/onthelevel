import SwiftUI

struct ColorUtils {
    static func colorForTilt(_ tilt: Double, difficulty: Difficulty) -> Color {
        let maxTilt = difficulty.maxDeviationForGreen
        let normalizedTilt = min(tilt / maxTilt, 1.0)
        
        if normalizedTilt <= 0.1 {
            return .green
        }
        
        let red = normalizedTilt
        let green = max(0, 1.0 - normalizedTilt)
        
        return Color(red: red, green: green, blue: 0)
    }
    
    static func backgroundGradient(for tilt: Double, difficulty: Difficulty) -> LinearGradient {
        let color = colorForTilt(tilt, difficulty: difficulty)
        
        return LinearGradient(
            colors: [color.opacity(0.8), color],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}