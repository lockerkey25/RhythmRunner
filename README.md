# RhythmRunner

A minimalist, stylish fitness app designed specifically for runners who want to synchronize their pace with music. RhythmRunner connects to popular music streaming platforms and provides AI-powered song recommendations based on your target BPM (beats per minute).

## Features

- **BPM-Based Running**: Choose from preset BPM options (120, 140, 160, 180) or set custom BPM
- **Metronome**: Built-in metronome with customizable tempo and toggle on/off
- **Music Integration**: Connect to Spotify for seamless music playback
- **AI Song Selection**: Intelligent song recommendations based on your target BPM
- **Workout Tracking**: Monitor your running sessions and track performance

- **120 BPM - Easy Jog**: Perfect for warm-up, cool-down, or recovery runs
- **140 BPM - Moderate Run**: Ideal for steady-state cardio and endurance training
- **160 BPM - Fast Run**: Great for tempo runs and building speed
- **180 BPM - Sprint**: High-intensity intervals and speed work
- **Custom BPM**: Set your own tempo (60-200 BPM range)

### App Structure
```
RhythmRunner/
├── Models/
│   └── BPMOption.swift          # BPM option definitions
├── Managers/
│   ├── AudioManager.swift       # Metronome and audio handling
│   ├── SpotifyManager.swift     # Spotify integration
│   └── WorkoutManager.swift     # Workout tracking
├── Views/
│   ├── BPMOptionCard.swift      # BPM selection cards
│   ├── CustomBPMView.swift      # Custom BPM interface
│   └── SongListView.swift       # Song selection interface
├── ContentView.swift            # Main app interface
└── RhythmRunnerApp.swift        # App entry point
```

### 🔧 Key Components

#### AudioManager
- Handles metronome functionality using AVFoundation
- Generates custom metronome sounds
- Manages audio playback and timing
- Provides volume control and metronome toggle

#### SpotifyManager
- Manages Spotify API integration
- Handles song recommendations based on BPM
- Tracks current playback state
- Provides mock data for development

#### WorkoutManager
- Tracks workout sessions and duration
- Manages workout history
- Provides workout statistics
- Handles session persistence

## Setup Instructions

### Prerequisites
- Xcode 14.0 or later
- iOS 16.0 or later
- Spotify account (for full functionality)

### Installation
1. Clone the repository
2. Open `RhythmRunner.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run the project

### Spotify Integration Setup
1. Create a Spotify Developer account
2. Register your app in the Spotify Developer Dashboard
3. Add your Spotify Client ID to the project
4. Configure URL schemes for authentication

## Usage

### Getting Started
1. Launch the app
2. Choose your target BPM from the preset options or set a custom BPM
3. Connect to Spotify for music recommendations
4. Start your workout with the play button
5. The metronome will begin, and if connected, music will start playing

### Features in Detail

#### BPM Selection
- Tap on any BPM card to select it
- Use the "Custom" option to set a specific BPM
- The selected BPM is highlighted and displayed prominently

#### Metronome
- Toggle metronome on/off with the switch
- Metronome automatically adjusts to your selected BPM
- Visual feedback shows when metronome is active

#### Music Integration
- Connect to Spotify with one tap
- Browse songs filtered by your target BPM
- Tap any song to start playback
- Current song is displayed with BPM information

#### Workout Tracking
- Sessions are automatically tracked when you start/stop
- View workout history and statistics
- Track songs played during each session

## Future Enhancements

### Planned Features
- **Real Spotify API Integration**: Replace mock data with actual Spotify API calls
- **Core Data Persistence**: Save workout history and user preferences
- **Advanced Analytics**: Detailed workout statistics and progress tracking
- **Social Features**: Share workouts and compete with friends
- **Custom Playlists**: Create and save BPM-specific playlists
- **Voice Commands**: Hands-free control during workouts
- **Apple Watch Integration**: Companion app for wearable devices

### Technical Improvements
- **AI BPM Analysis**: Implement actual AI for song BPM detection
- **Offline Mode**: Cache songs for offline playback
- **Background Audio**: Continue playback when app is in background
- **Push Notifications**: Workout reminders and achievements
- **HealthKit Integration**: Sync with Apple Health for comprehensive tracking

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support, please open an issue in the GitHub repository.

---
