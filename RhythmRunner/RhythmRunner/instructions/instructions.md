# Requirements Document for *180 BPM Song* App  

## 1. App Overview  
This app is for people who like running or working out with music. It helps them run to a chosen rhythm (beats per minute, like 180 bpm). The app connects to a music service, uses AI to make sure the music is perfectly on beat, and shows the music waveform while running. The app can also slightly speed up or slow down songs so they stay exactly on the chosen rhythm.  

---

## 2. Main Goals  
1. Let the user pick a running rhythm (for example, 180 bpm or 160 bpm).  
2. Play music from a streaming service and adjust it with AI to match the rhythm exactly.  
3. Show the music waveform on screen during a running session.  
4. Allow a metronome sound option instead of music.  
5. Show clear info about what each rhythm is good for.  

---

## 3. User Stories  

- **US-001**: As a user, I want to pick a bpm so that I can run with the right rhythm.  
- **US-002**: As a user, I want the music to stay perfectly on beat so that I can keep pace.  
- **US-003**: As a user, I want the app to speed up or slow down songs slightly so that they always match my bpm.  
- **US-004**: As a user, I want to see the music waveform so that I feel more connected to the beat.  
- **US-005**: As a user, I want to use a metronome instead of music so that I can train with just beats.  
- **US-006**: As a user, I want to see what each bpm is best for so that I can choose the right one for my workout.  

---

## 4. Features  

- **F-001: Pick BPM**  
  - What it does: User chooses a bpm option (like 180 or 160).  
  - When it appears: On the main screen.  
  - Error case: If no bpm is chosen, nothing starts.  

- **F-002: AI Music Adjustment**  
  - What it does: Uses AI to check the beat of the song and adjust playback speed so it matches the chosen bpm.  
  - When it appears: Once a song starts.  
  - Error case: If AI cannot adjust, show message “This song cannot be matched to bpm.”  

- **F-003: Waveform Display**  
  - What it does: Shows a moving waveform of the song while playing.  
  - When it appears: On the session screen after starting.  
  - Error case: If waveform cannot load, show text “Waveform not available.”  

- **F-004: Metronome Option**  
  - What it does: Plays a simple beat instead of music.  
  - When it appears: Toggle switch on the main screen.  
  - Error case: If sound fails, show message “Metronome not working.”  

- **F-005: BPM Info**  
  - What it does: Shows a small description and icon of when to use each bpm.  
  - When it appears: Next to each bpm option.  
  - Error case: If info cannot load, show default text “No info available.”  

---

## 5. Screens  

- **S-001: Main Screen**  
  - What’s on it: Title, list of bpm options with icons, description text, toggle for metronome, button to start session.  
  - How to get there: Opens when the app starts.  

- **S-002: Session Screen**  
  - What’s on it: Large waveform display, chosen bpm at the top, current song title, AI beat match indicator, play/pause button, back button.  
  - How to get there: Tap start on Main Screen.  

---

## 6. Data  

- **D-001**: List of bpm options (example: 180 bpm with description “fast pace for running,” 160 bpm with description “steady jog”).  
- **D-002**: User’s last chosen bpm.  
- **D-003**: If metronome toggle was on or off.  
- **D-004**: Connection status to music service.  
- **D-005**: AI adjustment data (speed factor applied to keep music on beat).  

---

## 7. Extra Details  

- Needs internet to connect to music streaming and AI processing.  
- Stores user’s last choice on the phone.  
- May need permission to access music services (like Spotify login).  
- Works in dark mode and light mode.  

---

## 8. Build Steps  

- **B-001**: Build S-001 with F-001 (list of bpms) and F-005 (info about bpms). Use D-001 for options.  
- **B-002**: Add metronome toggle (F-004) to S-001. Save state with D-003.  
- **B-003**: Add start button that opens S-002 (Session Screen).  
- **B-004**: Build S-002 with F-003 (waveform display) and show bpm from D-002.  
- **B-005**: Add F-002 (AI music adjustment) so songs play on beat, using D-005 for speed factor.  
- **B-006**: Add error handling for missing connection (use D-004).  
- **B-007**: Save last chosen bpm (D-002) so app remembers it next time.  
- **B-008**: Add light/dark mode support.  
