//
//  AudioManager.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import Foundation
import AudioToolbox

class AudioManager: ObservableObject {
    @Published var isPlaying = false
    @Published var currentBPM: Int = 140
    @Published var metronomeEnabled = true {
        didSet {
            print("🎵 Metronome enabled changed to: \(metronomeEnabled)")
            // Immediate response to toggle
            if !metronomeEnabled && isPlaying {
                print("🛑 Stopping metronome due to toggle off")
                stopMetronome()
            }
        }
    }
    @Published var volume: Float = 0.7
    
    // Ultra-simple components - no AVFoundation complexity
    private var dispatchTimer: DispatchSourceTimer?
    private let systemSoundID: SystemSoundID = 1104 // System tick sound (better for metronome)
    private let backgroundQueue = DispatchQueue(label: "metronome.background", qos: .userInitiated)
    
    init() {
        print("✅ AudioManager initialized (bulletproof system sound only)")
    }
    
    deinit {
        stopMetronome()
    }
    
    // MARK: - Ultra-Simple Metronome (SystemSound Only)
    
    func startMetronome() {
        print("🎵 startMetronome called - enabled: \(metronomeEnabled), isPlaying: \(isPlaying)")
        
        guard metronomeEnabled else {
            print("⚠️ Metronome disabled, not starting")
            return
        }
        
        // Prevent multiple instances
        if isPlaying {
            print("⚠️ Metronome already playing")
            return
        }
        
        print("🚀 Starting metronome at \(currentBPM) BPM")
        DispatchQueue.main.async {
            self.isPlaying = true
        }
        
        // Calculate interval in nanoseconds for DispatchSourceTimer
        let intervalNanos = UInt64(60.0 / Double(currentBPM) * 1_000_000_000)
        
        // Create high-precision dispatch timer
        dispatchTimer = DispatchSource.makeTimerSource(queue: backgroundQueue)
        
        // Configure timer to fire immediately, then repeat at interval
        dispatchTimer?.schedule(deadline: .now(), repeating: .nanoseconds(Int(intervalNanos)), leeway: .nanoseconds(1_000_000)) // 1ms leeway
        
        // Set timer event handler
        dispatchTimer?.setEventHandler { [weak self] in
            guard let self = self, self.isPlaying && self.metronomeEnabled else {
                print("⚠️ Metronome tick cancelled - not playing or disabled")
                return
            }
            
            // Play the click
            self.playClick()
        }
        
        // Start the timer
        dispatchTimer?.resume()
        
        print("✅ Metronome started successfully at \(currentBPM) BPM with high-precision timer")
    }
    
    func stopMetronome() {
        print("🛑 stopMetronome called")
        
        DispatchQueue.main.async {
            self.isPlaying = false
        }
        
        // Cancel dispatch timer
        dispatchTimer?.cancel()
        dispatchTimer = nil
        
        print("✅ Metronome stopped")
    }
    
    private func playClick() {
        // Ultra-simple: just use system sound (bulletproof, never fails)
        AudioServicesPlaySystemSound(systemSoundID)
    }
    
    func setBPM(_ bpm: Int) {
        print("🎵 Setting BPM to \(bpm)")
        currentBPM = bpm
        
        // Restart metronome if it's playing to apply new BPM
        if isPlaying {
            stopMetronome()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.startMetronome()
            }
        }
    }
    
    func toggleMetronome() {
        print("🔄 toggleMetronome called - current enabled: \(metronomeEnabled)")
        metronomeEnabled.toggle()
        print("🔄 Metronome toggled to: \(metronomeEnabled)")
        
        // The didSet will handle stopping if needed
    }
}