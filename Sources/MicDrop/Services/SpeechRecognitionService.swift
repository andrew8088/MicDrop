import Foundation
import Speech
import AVFoundation

protocol SpeechRecognitionServiceDelegate: AnyObject {
    func speechRecognitionService(_ service: SpeechRecognitionService, didRecognizeText text: String, isFinal: Bool)
    func speechRecognitionService(_ service: SpeechRecognitionService, didFailWithError error: Error)
}

class SpeechRecognitionService {
    weak var delegate: SpeechRecognitionServiceDelegate?

    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    private var useOnDeviceRecognition = true

    var isRecognizing: Bool {
        return recognitionTask != nil
    }

    init(locale: Locale = Locale(identifier: "en-US")) {
        speechRecognizer = SFSpeechRecognizer(locale: locale)
    }

    // MARK: - Recognition Control

    func startRecognition() throws {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw SpeechRecognitionError.recognizerNotAvailable
        }

        // Cancel any ongoing recognition
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest = recognitionRequest else {
            throw SpeechRecognitionError.unableToCreateRequest
        }

        // Configure request
        recognitionRequest.shouldReportPartialResults = true

        // Use on-device recognition if available
        if useOnDeviceRecognition && speechRecognizer.supportsOnDeviceRecognition {
            recognitionRequest.requiresOnDeviceRecognition = true
            print("Using on-device speech recognition")
        } else {
            print("Using server-based speech recognition")
        }

        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                self.delegate?.speechRecognitionService(self, didFailWithError: error)
                self.stopRecognition()
                return
            }

            if let result = result {
                let text = result.bestTranscription.formattedString
                let isFinal = result.isFinal

                self.delegate?.speechRecognitionService(self, didRecognizeText: text, isFinal: isFinal)

                if isFinal {
                    self.stopRecognition()
                }
            }
        }

        print("Speech recognition started")
    }

    func appendAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        recognitionRequest?.append(buffer)
    }

    func stopRecognition() {
        // Mark end of audio
        recognitionRequest?.endAudio()

        // Cancel task
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil

        print("Speech recognition stopped")
    }

    // MARK: - Configuration

    func setOnDeviceRecognition(_ enabled: Bool) {
        useOnDeviceRecognition = enabled
    }

    // MARK: - Cleanup

    deinit {
        stopRecognition()
    }
}

// MARK: - Errors

enum SpeechRecognitionError: Error {
    case recognizerNotAvailable
    case unableToCreateRequest

    var localizedDescription: String {
        switch self {
        case .recognizerNotAvailable:
            return "Speech recognizer is not available"
        case .unableToCreateRequest:
            return "Unable to create speech recognition request"
        }
    }
}
