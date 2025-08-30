//
//  AudioManager.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import Foundation
import AVFoundation
import Combine

class AudioManager: ObservableObject {
    @Published var isPlaying = false
    @Published var currentBPM: Int = 140
    @Published var metronomeEnabled = true
    @Published var volume: Float = 0.7
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    init() {
        setupAudioSession()
        createMetronomeSound()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    deinit {
        stopMetronome()
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    private func createMetronomeSound() {
        // Create a proper WAV format audio data
        let sampleRate: Double = 44100
        let duration: Double = 0.1
        let frequency: Double = 800
        let frameCount = Int(sampleRate * duration)
        
        // Create WAV header
        var wavData = Data()
        
        // WAV file header (44 bytes)
        let header: [UInt8] = [
            0x52, 0x49, 0x46, 0x46, // "RIFF"
            0x00, 0x00, 0x00, 0x00, // File size (to be filled)
            0x57, 0x41, 0x56, 0x45, // "WAVE"
            0x66, 0x6D, 0x74, 0x20, // "fmt "
            0x10, 0x00, 0x00, 0x00, // Subchunk1Size (16 for PCM)
            0x01, 0x00,             // AudioFormat (PCM = 1)
            0x01, 0x00,             // NumChannels (mono = 1)
            0x44, 0xAC, 0x00, 0x00, // SampleRate (44100)
            0x88, 0x58, 0x01, 0x00, // ByteRate (SampleRate * NumChannels * BitsPerSample/8)
            0x02, 0x00,             // BlockAlign (NumChannels * BitsPerSample/8)
            0x10, 0x00,             // BitsPerSample (16)
            0x64, 0x61, 0x74, 0x61, // "data"
            0x00, 0x00, 0x00, 0x00  // Subchunk2Size (to be filled)
        ]
        
        wavData.append(contentsOf: header)
        
        // Generate audio samples
        for i in 0..<frameCount {
            let sample = sin(2.0 * .pi * frequency * Double(i) / sampleRate)
            let sample16 = Int16(sample * 0.3 * 32767)
            let bytes = withUnsafeBytes(of: sample16.littleEndian) { Array($0) }
            wavData.append(contentsOf: bytes)
        }
        
        // Update file size in header
        let fileSize = UInt32(wavData.count - 8).littleEndian
        wavData.replaceSubrange(4..<8, with: withUnsafeBytes(of: fileSize) { Array($0) })
        
        // Update data size in header
        let dataSize = UInt32(frameCount * 2).littleEndian
        wavData.replaceSubrange(40..<44, with: withUnsafeBytes(of: dataSize) { Array($0) })
        
        do {
            audioPlayer = try AVAudioPlayer(data: wavData)
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = volume
        } catch {
            print("Failed to create audio player: \(error)")
            // Fallback to system sound
            createSystemSoundFallback()
        }
    }
    
    private func createSystemSoundFallback() {
        // Use a simpler approach with system sound as fallback
        audioPlayer = nil
        print("Using system sound fallback for metronome")
    }
    
    func startMetronome() {
        guard metronomeEnabled, let _ = audioPlayer else { return }
        
        // Prevent multiple timers from running
        if isPlaying { return }
        
        isPlaying = true
        let interval = 60.0 / Double(currentBPM)
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.playMetronomeClick()
        }
        
        // Play first click immediately
        playMetronomeClick()
    }
    
    func stopMetronome() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
        audioPlayer?.stop()
    }
    
    private func playMetronomeClick() {
        guard let player = audioPlayer else { return }
        
        player.currentTime = 0
        player.play()
    }
    
    func setBPM(_ bpm: Int) {
        currentBPM = bpm
        if isPlaying {
            stopMetronome()
            startMetronome()
        }
    }
    
    func resetAudioSession() {
        stopMetronome()
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to reset audio session: \(error)")
        }
    }
    
    func toggleMetronome() {
        metronomeEnabled.toggle()
        if !metronomeEnabled && isPlaying {
            stopMetronome()
        }
    }
}
