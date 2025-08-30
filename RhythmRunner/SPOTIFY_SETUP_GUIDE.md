# Spotify API Integration Setup Guide

This guide will help you complete the Spotify API integration for your RhythmRunner app.

## 📋 Prerequisites

1. **Spotify Account**: You need a Spotify account (Premium recommended for full playback control)
2. **Spotify Developer Account**: Sign up at [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
3. **Xcode 14.0+**: Required for iOS 16.0+ features
4. **Active Spotify App**: You'll need the Spotify app installed on your test device

## 🚀 Quick Setup Steps

### 1. Create a Spotify App

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Click "Create App"
3. Fill in the details:
   - **App Name**: RhythmRunner
   - **App Description**: BPM-based fitness music app
   - **Website**: (optional)
   - **Redirect URI**: `rhythmrunner://spotify-callback`
4. Check the boxes for required APIs
5. Click "Save"
6. Note your **Client ID** from the app settings

### 2. Configure Your App

1. Open `SpotifyConfig.swift`
2. Replace `YOUR_SPOTIFY_CLIENT_ID` with your actual Client ID:
   ```swift
   static let clientID = "your_actual_client_id_here"
   ```

### 3. Add Files to Xcode Project

Make sure all the new files are added to your Xcode project:

- `SpotifyConfig.swift`
- `SpotifyModels.swift`
- `SpotifyAPIService.swift`
- `SpotifyAuthService.swift`
- `Info.plist` (updated)
- `RhythmRunner.entitlements` (updated)

### 4. Update Bundle Settings in Xcode

1. Open your project in Xcode
2. Go to your target settings → Info
3. Make sure the URL schemes are properly configured (should be automatic from Info.plist)

### 5. Test the Integration

1. Build and run the app
2. Try connecting to Spotify
3. Test BPM-based song recommendations
4. Test playback controls

## 🔧 Key Features Implemented

### ✅ Authentication
- OAuth 2.0 with PKCE (Proof Key for Code Exchange)
- Secure token storage and refresh
- Automatic token management

### ✅ Song Discovery
- BPM-based song recommendations
- Audio features analysis (energy, danceability, etc.)
- Genre-based search queries
- Intelligent song filtering

### ✅ Playback Control
- Play specific tracks
- Pause/resume playback
- Real-time playback state monitoring
- Device management

### ✅ Error Handling
- Network error management
- Token expiration handling
- Fallback to mock data
- User-friendly error messages

## 📱 How It Works

### Authentication Flow
1. User taps "Connect to Spotify"
2. App opens Spotify login in secure web view
3. User authorizes the app
4. App receives authorization code
5. App exchanges code for access/refresh tokens
6. Tokens are stored securely

### Song Recommendation Flow
1. User selects target BPM (e.g., 140 BPM)
2. App searches Spotify with genre-specific queries
3. App retrieves audio features for found tracks
4. App filters songs by BPM tolerance (±10 BPM)
5. App ranks songs by fitness score (energy + danceability + valence)
6. Top recommendations are displayed

### Playback Flow
1. User selects a song from recommendations
2. App sends playback request to Spotify Web API
3. Song plays on user's active Spotify device
4. App monitors playback state
5. App updates UI with current playing song

## 🛠️ Advanced Configuration

### Customizing BPM Tolerance
In `SpotifyManager.swift`, adjust the tolerance:
```swift
private let bpmTolerance: Double = 15.0 // Default is 10.0
```

### Modifying Search Queries
Update `generateSearchQueries(for:)` method to add more genres or search terms:
```swift
private func generateSearchQueries(for bpm: Int) -> [String] {
    // Add your custom genres here
    let customGenres = ["your-genre", "another-genre"]
    // ...
}
```

### Adjusting Fitness Scoring
Modify the scoring algorithm in `filterSongsByBPM`:
```swift
let energyScore = audioFeature.energy * 0.5      // Increase energy weight
let danceabilityScore = audioFeature.danceability * 0.3
let valenceScore = audioFeature.valence * 0.1
let bpmScore = (1.0 - (bpmDifference / bpmTolerance)) * 0.1
```

## 🔒 Security Notes

- Tokens are stored in UserDefaults (consider Keychain for production)
- Client secret is not used (PKCE flow is more secure)
- All API calls use HTTPS
- Tokens are automatically refreshed

## 🐛 Troubleshooting

### Common Issues

1. **"Client ID not configured"**
   - Make sure you've updated `SpotifyConfig.swift` with your actual Client ID

2. **"Redirect URI mismatch"**
   - Ensure your Spotify app settings match the redirect URI in `SpotifyConfig.swift`

3. **"No active device found"**
   - Make sure Spotify app is open and active on the device
   - Try playing something in Spotify first to activate the device

4. **"Premium required" errors**
   - Some playback features require Spotify Premium
   - Web playback works with free accounts but with limitations

5. **Songs not loading**
   - Check internet connection
   - Verify API credentials
   - App falls back to mock data if API fails

### Debug Modes

Enable additional logging by adding to `SpotifyAPIService.swift`:
```swift
private let debugLogging = true

private func logRequest(_ request: URLRequest) {
    if debugLogging {
        print("Spotify API Request: \(request.url?.absoluteString ?? "")")
    }
}
```

## 🎵 Testing Without Spotify Premium

The app includes comprehensive mock data fallback:
- Mock songs with realistic BPM values
- Simulated API delays for realistic testing
- Full UI functionality without API connection
- Graceful degradation when API calls fail

## 📈 Next Steps

### Potential Enhancements
1. **Playlist Creation**: Save BPM-specific playlists
2. **Offline Mode**: Cache favorite workout songs
3. **Social Features**: Share workout playlists
4. **Analytics**: Track listening habits and workout patterns
5. **Apple Watch**: Companion app for wrist control

### Production Checklist
- [ ] Replace UserDefaults with Keychain for token storage
- [ ] Add proper error analytics/logging
- [ ] Implement rate limiting for API calls
- [ ] Add comprehensive unit tests
- [ ] Submit app for Spotify review (if needed)

## 🆘 Support

If you encounter issues:
1. Check the Xcode console for error messages
2. Verify all setup steps were completed
3. Test with mock data first
4. Review Spotify Developer documentation
5. Check your app's Spotify dashboard for quota/usage issues

---

Your Spotify integration is now complete! The app will intelligently recommend songs based on your target BPM and provide seamless playback control. 🎵🏃‍♂️
