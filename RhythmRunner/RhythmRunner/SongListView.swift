//
//  SongListView.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import SwiftUI

struct SongListView: View {
    let bpm: Int
    @EnvironmentObject var spotifyManager: SpotifyManager
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: colorScheme == .dark ? 
                                      [Color.black, Color.gray.opacity(0.3)] : 
                                      [Color.white, Color.blue.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        Text("Songs for \(bpm) BPM")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        Text("Perfect tempo for your run")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Song List
                    if spotifyManager.isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                            .foregroundColor(.white)
                        Spacer()
                    } else if spotifyManager.recommendedSongs.isEmpty {
                        Spacer()
                        VStack(spacing: 15) {
                            Image(systemName: "music.note.slash")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("No songs found")
                                .font(.headline)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            
                            Text("Try a different BPM or check your Spotify connection")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(spotifyManager.recommendedSongs) { song in
                                    SongRow(
                                        song: song,
                                        isPlaying: spotifyManager.currentSong?.id == song.id
                                    ) {
                                        spotifyManager.playSong(song)
                                        if workoutManager.isWorkoutActive {
                                            workoutManager.addSongToSession(song.title)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
        }
        .onAppear {
            spotifyManager.getSongsForBPM(bpm)
        }
    }
}

struct SongRow: View {
    let song: Song
    let isPlaying: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Album Art Placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(.gray)
                    )
                
                // Song Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .lineLimit(1)
                    
                    Text(song.artist)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    Text(song.album)
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.8))
                        .lineLimit(1)
                }
                
                Spacer()
                
                // BPM Badge
                Text("\(song.bpm)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.green.opacity(0.3))
                    )
                
                // Play Indicator
                if isPlaying {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                } else {
                    Image(systemName: "play.circle")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .font(.title3)
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isPlaying ? Color.green : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SongListView(bpm: 160)
        .environmentObject(SpotifyManager())
        .environmentObject(WorkoutManager())
}
