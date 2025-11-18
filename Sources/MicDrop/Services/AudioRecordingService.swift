import Foundation
import AVFoundation

protocol AudioRecordingServiceDelegate: AnyObject {
    func audioRecordingService(_ service: AudioRecordingService, didReceiveBuffer buffer: AVAudioPCMBuffer, time: AVAudioTime)
    func audioRecordingServiceDidFinishRecording(_ service: AudioRecordingService)
}

class AudioRecordingService {
    weak var delegate: AudioRecordingServiceDelegate?

    private let audioEngine = AVAudioEngine()
    private var inputNode: AVAudioInputNode?
    private var isRecording = false

    var currentlyRecording: Bool {
        return isRecording
    }

    // MARK: - Recording Control

    func startRecording() throws {
        guard !isRecording else { return }

        // Get the input node
        inputNode = audioEngine.inputNode

        guard let inputNode = inputNode else {
            throw AudioRecordingError.noInputNode
        }

        // Get the input format
        let inputFormat = inputNode.outputFormat(forBus: 0)

        // Install tap to capture audio buffers
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] buffer, time in
            guard let self = self else { return }
            self.delegate?.audioRecordingService(self, didReceiveBuffer: buffer, time: time)
        }

        // Prepare and start the audio engine
        audioEngine.prepare()
        try audioEngine.start()

        isRecording = true
        print("Audio recording started")
    }

    func stopRecording() {
        guard isRecording else { return }

        // Remove tap and stop engine
        inputNode?.removeTap(onBus: 0)
        audioEngine.stop()

        isRecording = false
        print("Audio recording stopped")

        delegate?.audioRecordingServiceDidFinishRecording(self)
    }

    // MARK: - Cleanup

    deinit {
        if isRecording {
            stopRecording()
        }
    }
}

// MARK: - Errors

enum AudioRecordingError: Error {
    case noInputNode
    case engineStartFailed

    var localizedDescription: String {
        switch self {
        case .noInputNode:
            return "No audio input device found"
        case .engineStartFailed:
            return "Failed to start audio engine"
        }
    }
}
