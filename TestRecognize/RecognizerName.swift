//
//  Recognizer.swift
//  TestRecognize
//
//  Created by Доловсков Владислав on 07.12.2017.
//  Copyright © 2017 Доловсков Владислав. All rights reserved.
//

import Foundation
import Speech

protocol RecognizerNameDelegade {
    func showName(name: String)
}

class RecognizerName: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    let delegate: RecognizerNameDelegade
    
    var capture: AVCaptureSession?
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    fileprivate var iOS10RecognitionRelease: (() -> Void)? = nil
    var speechText = String()
    
    var repeatTimer = Timer()
    var nameStandbyTimer = Timer()
    
    var isResOnStandby = true
    var nameTimerCreate = false
    
    init(delegate: RecognizerNameDelegade) {
        self.delegate = delegate
    }
    
    
    func restartTimer() {
        isResOnStandby = true
        repeatTimer.invalidate()
        repeatTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(timerCheck), userInfo: nil, repeats: false)
    }
    
    @objc func timerCheck() {
        if isResOnStandby {
            self.endCapture()
            self.startRecognize()
        }
    }
    
    func startRecognize() {
        print("start recognize")
        self.speechText = ""
        self.nameTimerCreate = false
        restartTimer()
        startCapture()
    }
    
    @objc func checkSpeech() {
        self.endCapture()
        let checkText = self.speechText
        if checkText.count > 11 {
            let name = String(checkText.suffix(from: String.Index.init(encodedOffset: 11)))
            self.showName(name: name)
        } else {
            self.startRecognize()
        }
    }
    
    func showName(name: String) {
        delegate.showName(name: name)
    }
    
    func startCapture() {
        let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en"))!
        var recognitionTask: SFSpeechRecognitionTask?
        
        capture = AVCaptureSession()
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let audioDev = AVCaptureDevice.default(for: AVMediaType.audio) else {
            print("Could not get capture device.")
            return
        }
        
        guard let audioIn = try? AVCaptureDeviceInput(device: audioDev) else {
            print("Could not create input device.")
            return
        }
        
        guard true == capture?.canAddInput(audioIn) else {
            print("Couls not add input device")
            return
        }
        
        capture?.addInput(audioIn)
        
        let audioOut = AVCaptureAudioDataOutput()
        audioOut.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        
        guard true == capture?.canAddOutput(audioOut) else {
            print("Could not add audio output")
            return
        }
        
        iOS10RecognitionRelease = {
            print("stopping capture")
            
            recognitionTask?.cancel()
            self.recognitionRequest?.endAudio()
            
            if true == self.capture?.isRunning {
                self.capture?.stopRunning()
            }
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { result, error in
            
            if let result = result {
                self.speechText = result.bestTranscription.formattedString
                print(self.speechText)
                let checkText = self.speechText
                if (checkText.count > 7 && !checkText.hasPrefix("My")) {
                    self.endCapture()
                    self.startRecognize()
                }
                if checkText.count > 11 {
                    if checkText.hasPrefix("My name is ") {
                        self.isResOnStandby = false
                        if !self.nameTimerCreate {
                            self.nameStandbyTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkSpeech), userInfo: nil, repeats: false)
                        }
                    } else {
                        self.endCapture()
                        self.startRecognize()
                    }
                }
            }
        }
        
        capture?.addOutput(audioOut)
        audioOut.connection(with: AVMediaType.audio)
        capture?.startRunning()
        
        
    }
    
    func endCapture() {
        iOS10RecognitionRelease?()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        recognitionRequest?.appendAudioSampleBuffer(sampleBuffer)
    }
    
}
