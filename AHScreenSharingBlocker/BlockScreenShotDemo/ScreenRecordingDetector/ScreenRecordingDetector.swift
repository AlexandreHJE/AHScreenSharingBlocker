//
//  ScreenRecordingDetector.swift
//  BlockScreenShotDemo
//
//  Created by Alex Hu on 2021/4/30.
//

import UIKit

class ScreenRecordingDetector {
    private let screenRecordingDetectorTimerInterval: Double = 1.0
    private let screenRecordingDetectorRecordingStatusChangedNotification: String = "screenRecordingDetectorRecordingStatusChangedNotification"
    
    private var lastRecordingStatus: Bool = false
    private var timer: Timer?
    
    static let shared = ScreenRecordingDetector()
    
    private init() {}
    
    func isRecording() -> Bool {
        for screen in UIScreen.screens {
            if screen.isCaptured {
                return true
            } else if screen.mirrored != nil {
                return true
            }
        }
        
        return false
    }
    
    private func triggerDetectorTimer() {
        let detector = ScreenRecordingDetector.shared
        if detector.timer != nil {
            detector.stopDetectorTimer()
        }
        detector.timer = Timer(timeInterval: screenRecordingDetectorTimerInterval, target: detector, selector: #selector(checkCurrentRecordingStatus), userInfo: nil, repeats: true)
    }
    
    @objc private func checkCurrentRecordingStatus(timer: Timer) {
        if lastRecordingStatus != isRecording() {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: screenRecordingDetectorRecordingStatusChangedNotification), object: nil)
        }
        lastRecordingStatus = isRecording()
    }
    
    private func stopDetectorTimer() {
        let detector = ScreenRecordingDetector.shared
        guard detector.timer != nil else { return }
        detector.timer?.invalidate()
        detector.timer = nil
    }
}
