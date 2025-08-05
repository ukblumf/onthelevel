# On The Level - iOS Spirit Level Game

A simple iOS game that challenges players to keep their iPhone perfectly level while walking or performing maneuvers. Similar to a digital spirit level, the screen changes from bright green (level) to varying shades of red as the device becomes less level.

## Game Features

### Core Gameplay
- **Real-time tilt detection** using Core Motion framework
- **Visual feedback** - Green (level) to Red (tilted) color transitions
- **Timer-based challenges** with customizable duration (default 20 seconds)
- **Scoring system** - Lower scores are better, 0 is perfect
- **Difficulty levels** - Easy, Medium, Hard, Insane with different sensitivity

### Difficulty Settings
- **Easy**: Up to 10° tilt stays green, forgiving sensitivity
- **Medium**: Up to 5° tilt stays green, balanced sensitivity  
- **Hard**: Up to 2° tilt stays green, challenging sensitivity
- **Insane**: Only 1° tilt stays green, extreme sensitivity

### Game Screens
- **Main Menu** - Play, Settings, How to Play
- **Game Screen** - Real-time color feedback and level indicator
- **Settings** - Difficulty and timer duration adjustment
- **Results** - Score display with performance statistics and sharing

## Technical Implementation

### Architecture
- **SwiftUI** for modern iOS UI
- **MVVM pattern** with ViewModels managing game state
- **Core Motion** for accelerometer and gyroscope data
- **Combine** for reactive programming and data binding

### Key Components
- `MotionService` - Handles device motion detection and tilt calculations
- `GameViewModel` - Manages game state, scoring, and timer
- `ColorUtils` - Calculates background colors based on tilt and difficulty
- `GameSettings` & `GameScore` models for data management

### File Structure
```
OnTheLevel/
├── App/
│   ├── OnTheLevelApp.swift      # App entry point
│   └── ContentView.swift        # Root view with navigation
├── Views/
│   ├── MenuView.swift           # Main menu screen
│   ├── GameView.swift           # Main game screen with color feedback
│   ├── SettingsView.swift       # Settings configuration
│   └── ResultsView.swift        # Post-game results and sharing
├── ViewModels/
│   ├── GameViewModel.swift      # Game logic and state management
│   └── SettingsViewModel.swift  # Settings state management
├── Models/
│   ├── GameSettings.swift       # Game configuration model
│   └── GameScore.swift          # Score and statistics model
├── Services/
│   └── MotionService.swift      # Core Motion integration
└── Utils/
    └── ColorUtils.swift         # Color calculation utilities
```

## Requirements

- **iOS 17.0+**
- **Xcode 15.0+**
- **Physical device required** (Motion sensors don't work in simulator)
- **Device capabilities**: Accelerometer, Gyroscope

## Setup Instructions

1. Open `OnTheLevel.xcodeproj` in Xcode
2. Select your development team in project settings
3. Build and run on a physical iOS device
4. Grant motion sensor permissions when prompted

## How to Play

1. **Hold Your Phone**: Hold your iPhone flat and level, like a spirit level
2. **Start the Game**: Tap play and try to keep the screen green
3. **Beat the Clock**: Maintain level orientation for the full duration
4. **Watch Your Score**: Every degree of tilt adds to your score - aim for 0!
5. **Challenge Yourself**: Increase difficulty for more sensitive tilt detection

## Features

- Real-time motion detection with 60fps updates
- Smooth color transitions and animations
- Level indicator bubble showing tilt direction
- Score sharing functionality
- Performance statistics tracking
- Difficulty-based sensitivity scaling

## Notes

- **Physical Device Required**: Core Motion APIs only work on actual iOS devices
- **Portrait Orientation**: Game is designed for portrait mode only
- **Motion Permissions**: App requests motion sensor access on first launch
- **Calibration**: Device should be held flat for best results

Enjoy the challenge of staying perfectly level! 🎯