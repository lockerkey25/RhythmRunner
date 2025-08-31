# RhythmRunner - Enhanced Fitness Music App

A modern, fitness-focused iOS app that helps runners and athletes maintain their pace with BPM-synchronized music and metronome functionality.

## ✨ Recent Improvements

### 🎯 Enhanced User Experience
- **Smooth Transitions**: Changed from sliding up to zoom-in animations for better visual flow
- **Modern Typography**: Implemented SF Pro Display and SF Pro Text fonts throughout the app for a premium, fitness-focused look
- **Improved Gestures**: Enhanced double-tap functionality with better haptic feedback and visual cues
- **Optimized Scrolling**: Fixed metronome sound interruption during scrolling with robust audio session management

### 🎵 Audio & Metronome Enhancements
- **Robust Audio Session**: Improved audio session handling with interruption and route change support
- **Enhanced Metronome**: Better sound quality with envelope shaping and higher frequency clarity
- **Continuous Playback**: Metronome now continues playing during scrolling and other UI interactions
- **Audio Interruption Handling**: Smart pause/resume functionality for phone calls and other interruptions

### 🎧 Spotify Integration Improvements
- **Enhanced Authentication**: Added additional scopes for better user experience
- **Improved Error Handling**: Better error messages and troubleshooting tips
- **Device Management**: Better handling of Spotify device connections
- **Fallback Support**: Comprehensive mock data when API is unavailable

### 🎨 Visual & UI Improvements
- **Consistent Font System**: Centralized font configuration for maintainability
- **Enhanced Animations**: Smooth transitions and micro-interactions
- **Better Visual Hierarchy**: Improved spacing, shadows, and color usage
- **Dark Mode Support**: Optimized for both light and dark themes

## 🚀 Features

### Core Functionality
- **BPM Selection**: Choose from preset BPM options (120-180 BPM) or set custom values
- **Metronome**: High-quality metronome with customizable volume and BPM
- **Spotify Integration**: Connect to Spotify for BPM-matched music recommendations
- **Workout Tracking**: Session management with duration tracking
- **Real-time Feedback**: Visual and audio feedback during workouts

### Advanced Features
- **Double-tap Quick Start**: Start sessions quickly with double-tap on BPM cards
- **Audio Session Management**: Robust handling of audio interruptions and device changes
- **Network Monitoring**: Smart fallbacks when internet connection is poor
- **Responsive Design**: Optimized for all iOS devices and orientations

## 🛠️ Technical Improvements

### Audio System
- Enhanced AVAudioSession configuration
- Notification-based interruption handling
- Route change detection and management
- Improved metronome sound generation

### Performance
- Optimized scrolling performance
- Better memory management
- Reduced audio latency
- Improved gesture responsiveness

### Code Quality
- Centralized font configuration
- Better error handling
- Improved code organization
- Enhanced maintainability

## 📱 Requirements

- iOS 16.0+
- Xcode 14.0+
- Spotify Premium account (recommended)
- Active internet connection

## 🔧 Setup

1. Clone the repository
2. Open `RhythmRunner.xcodeproj` in Xcode
3. Configure your Spotify API credentials in `SpotifyConfig.swift`
4. Build and run on your device

## 🎯 Usage

1. **Launch**: App starts with a smooth welcome screen
2. **Select BPM**: Choose your target running tempo
3. **Connect Spotify**: Link your Spotify account for music
4. **Start Session**: Use single tap to select or double-tap to start immediately
5. **Enjoy**: Run to the beat with synchronized music or metronome

## 🎨 Design Philosophy

The app follows modern iOS design principles with:
- **Fitness-Focused Typography**: SF Pro Display for headings, SF Pro Text for body text
- **Smooth Animations**: Spring-based animations for natural feel
- **Accessible Design**: High contrast and readable text sizes
- **Responsive Layout**: Adapts to different screen sizes and orientations

## 🔮 Future Enhancements

- Apple Watch companion app
- Offline music caching
- Social features and workout sharing
- Advanced analytics and progress tracking
- Custom workout playlists
- Integration with fitness apps

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

**RhythmRunner** - Run to the Beat, Every Time! 🏃‍♂️🎵
