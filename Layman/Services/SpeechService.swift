import Foundation
import Speech
import AVFoundation
import SwiftUI

/// Speech-to-text service using Apple's Speech framework.
@Observable
final class SpeechService {
    var isRecording = false
    var transcript = ""
    var permissionGranted = false
    var errorMessage: String?
    var showPermissionAlert = false

    private var audioEngine: AVAudioEngine?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?

    var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    /// Requests both speech and mic permissions. Calls completion with true if both granted.
    func requestPermission(completion: ((Bool) -> Void)? = nil) {
        #if targetEnvironment(simulator)
        permissionGranted = false
        errorMessage = "Voice input requires a real device. Not available on simulator."
        showPermissionAlert = true
        completion?(false)
        return
        #else
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            let speechGranted = status == .authorized
            AVAudioSession.sharedInstance().requestRecordPermission { micGranted in
                Task { @MainActor [weak self] in
                    let allGranted = speechGranted && micGranted
                    self?.permissionGranted = allGranted
                    if !allGranted {
                        self?.showPermissionAlert = true
                        if !speechGranted {
                            self?.errorMessage = "Speech recognition not authorized. Enable in Settings > Privacy."
                        } else {
                            self?.errorMessage = "Microphone not authorized. Enable in Settings > Privacy."
                        }
                    }
                    completion?(allGranted)
                }
            }
        }
        #endif
    }

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    func startRecording() {
        #if targetEnvironment(simulator)
        errorMessage = "Voice input requires a real device. Not available on simulator."
        showPermissionAlert = true
        return
        #else
        guard !isRecording else { return }

        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        guard let recognizer = recognizer, recognizer.isAvailable else {
            errorMessage = "Speech recognition not available on this device"
            showPermissionAlert = true
            return
        }

        // Cancel previous
        recognitionTask?.cancel()
        recognitionTask = nil
        transcript = ""

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Could not set up audio session: \(error.localizedDescription)"
            showPermissionAlert = true
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        let engine = AVAudioEngine()
        audioEngine = engine

        let inputNode = engine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                if let result = result {
                    self.transcript = result.bestTranscription.formattedString
                    if result.isFinal {
                        self.stopRecording()
                    }
                }
                if let error = error {
                    // Don't treat cancellation as user-facing error
                    let nsError = error as NSError
                    if nsError.domain != "kAFAssistantErrorDomain" || nsError.code != 216 {
                        self.errorMessage = "Recognition error: \(error.localizedDescription)"
                    }
                    self.stopRecording()
                }
            }
        }

        do {
            engine.prepare()
            try engine.start()
            isRecording = true
        } catch {
            errorMessage = "Could not start audio engine: \(error.localizedDescription)"
            showPermissionAlert = true
            stopRecording()
        }
        #endif
    }

    func stopRecording() {
        guard isRecording || audioEngine != nil else { return }
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        audioEngine = nil
        isRecording = false
    }
}

// UI polish

// UI polish

// Refactoring
