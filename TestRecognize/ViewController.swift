//
//  ViewController.swift
//  TestRecognize
//
//  Created by Доловсков Владислав on 07.12.2017.
//  Copyright © 2017 Доловсков Владислав. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {
    
    var capture: AVCaptureSession?
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    fileprivate var iOS10RecognitionRelease: (() -> Void)? = nil
    var speechText = String()
    
    var repeatTimer = Timer()
    var nameStandbyTimer = Timer()
    
    var isResOnStandby = true
    var nameTimerCreate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRecognize()
        
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
        let name = checkText.suffix(from: String.Index.init(encodedOffset: 11))
        self.showName(name: String(name))
    }
    
    func showName(name: String) {
        let alert = UIAlertController(title: "Hello \(name)", message: nil, preferredStyle: .alert)
        let tryAgainButton = UIAlertAction(title: "Try again", style: .default) { (action) in
            self.startRecognize()
        }
        alert.addAction(tryAgainButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func startCapture() {
        let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
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
            
//            self.speechRecognitionTimeout?.invalidate()
//            self.speechRecognitionTimeout = nil
            
            recognitionTask?.cancel()
            self.recognitionRequest?.endAudio()
            
            if true == self.capture?.isRunning {
                self.capture?.stopRunning()
            }
        }
        
         recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { result, error in
            
            if let result = result {
                self.speechText = result.bestTranscription.formattedString
                let checkText = self.speechText
                if (checkText.count > 2 && !checkText.hasPrefix("My")) || (checkText.count > 7 && !checkText.hasPrefix("My name")) {
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
}

extension ViewController: AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        recognitionRequest?.appendAudioSampleBuffer(sampleBuffer)
    }
    
}

extension ViewController: SFSpeechRecognitionTaskDelegate {
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        print(recognitionResult.bestTranscription.formattedString)
    }
}
