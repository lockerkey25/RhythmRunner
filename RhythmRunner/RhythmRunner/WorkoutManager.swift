//
//  WorkoutManager.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import Foundation
import Combine

struct WorkoutSession: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date?
    let targetBPM: Int
    let duration: TimeInterval
    let songsPlayed: [String]
    
    init(startTime: Date, endTime: Date?, targetBPM: Int, duration: TimeInterval, songsPlayed: [String]) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.targetBPM = targetBPM
        self.duration = duration
        self.songsPlayed = songsPlayed
    }
    
    enum CodingKeys: String, CodingKey {
        case id, startTime, endTime, targetBPM, duration, songsPlayed
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decodeIfPresent(Date.self, forKey: .endTime)
        targetBPM = try container.decode(Int.self, forKey: .targetBPM)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        songsPlayed = try container.decode([String].self, forKey: .songsPlayed)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(startTime, forKey: .startTime)
        try container.encodeIfPresent(endTime, forKey: .endTime)
        try container.encode(targetBPM, forKey: .targetBPM)
        try container.encode(duration, forKey: .duration)
        try container.encode(songsPlayed, forKey: .songsPlayed)
    }
}

class WorkoutManager: ObservableObject {
    @Published var isWorkoutActive = false
    @Published var currentSession: WorkoutSession?
    @Published var workoutHistory: [WorkoutSession] = []
    @Published var totalWorkoutTime: TimeInterval = 0
    @Published var currentWorkoutStartTime: Date?
    @Published var workoutDuration: TimeInterval = 0
    @Published var formattedDuration: String = "00:00"
    @Published var sessionType: SessionType = .freeRun
    @Published var selectedDuration: RunningDuration?
    @Published var isTimedSession: Bool = false
    @Published var timeRemaining: TimeInterval = 0
    @Published var formattedTimeRemaining: String = "00:00"
    
    private var workoutTimer: Timer?
    
    init() {
        loadWorkoutHistory()
    }
    
    func startWorkout(targetBPM: Int, sessionType: SessionType, duration: RunningDuration? = nil) {
        isWorkoutActive = true
        currentWorkoutStartTime = Date()
        self.sessionType = sessionType
        self.selectedDuration = duration
        
        // Set up timed session
        if sessionType == .timed, let duration = duration {
            isTimedSession = true
            timeRemaining = duration.duration
            formattedTimeRemaining = formatDuration(timeRemaining)
        } else {
            isTimedSession = false
        }
        
        currentSession = WorkoutSession(
            startTime: Date(),
            endTime: nil,
            targetBPM: targetBPM,
            duration: 0,
            songsPlayed: []
        )
        
        startTimer()
    }
    
    func stopWorkout() {
        isWorkoutActive = false
        workoutTimer?.invalidate()
        workoutTimer = nil
        
        guard let startTime = currentWorkoutStartTime else { return }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        totalWorkoutTime += duration
        
        if let session = currentSession {
            let updatedSession = WorkoutSession(
                startTime: session.startTime,
                endTime: endTime,
                targetBPM: session.targetBPM,
                duration: duration,
                songsPlayed: session.songsPlayed
            )
            
            workoutHistory.append(updatedSession)
            saveWorkoutHistory()
        }
        
        currentSession = nil
        currentWorkoutStartTime = nil
        isTimedSession = false
        timeRemaining = 0
        formattedTimeRemaining = "00:00"
    }
    
    private func startTimer() {
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateWorkoutTime()
        }
    }
    
    private func updateWorkoutTime() {
        guard let startTime = currentWorkoutStartTime else { return }
        let currentDuration = Date().timeIntervalSince(startTime)
        workoutDuration = currentDuration
        totalWorkoutTime = currentDuration
        formattedDuration = formatDuration(currentDuration)
        
        // Update countdown for timed sessions
        if isTimedSession {
            timeRemaining = max(0, (selectedDuration?.duration ?? 0) - currentDuration)
            formattedTimeRemaining = formatDuration(timeRemaining)
            
            // Auto-stop when timer reaches zero
            if timeRemaining <= 0 {
                stopWorkout()
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func addSongToSession(_ songTitle: String) {
        guard let session = currentSession else { return }
        var songs = session.songsPlayed
        songs.append(songTitle)
        
        currentSession = WorkoutSession(
            startTime: session.startTime,
            endTime: session.endTime,
            targetBPM: session.targetBPM,
            duration: session.duration,
            songsPlayed: songs
        )
    }
    
    // MARK: - Session Statistics
    
    var songsPlayedCount: Int {
        return currentSession?.songsPlayed.count ?? 0
    }
    
    var completionPercentage: Double {
        guard isTimedSession, let duration = selectedDuration else { return 0 }
        let elapsed = workoutDuration
        return min(100, (elapsed / duration.duration) * 100)
    }
    
    func getWorkoutStats() -> (totalSessions: Int, totalTime: TimeInterval, averageBPM: Int) {
        let totalSessions = workoutHistory.count
        let totalTime = workoutHistory.reduce(0) { $0 + $1.duration }
        let averageBPM = workoutHistory.isEmpty ? 0 : Int(Double(workoutHistory.reduce(0) { $0 + $1.targetBPM }) / Double(workoutHistory.count))
        
        return (totalSessions, totalTime, averageBPM)
    }
    
    private func saveWorkoutHistory() {
        // TODO: Implement Core Data persistence
        print("Saving workout history: \(workoutHistory.count) sessions")
    }
    
    private func loadWorkoutHistory() {
        // TODO: Implement Core Data loading
        print("Loading workout history")
    }
}
