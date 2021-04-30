//
//  ViewController.swift
//  BlockScreenShotDemo
//
//  Created by Alex Hu on 2021/4/28.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var screenRecordingStatusLabel: UILabel!
    @IBOutlet weak var protectedContentLabel: UILabel!
    @IBOutlet weak var contentProtectingLayer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(setupProtectingLayer), name: NSNotification.Name(rawValue: "screenRecordingDetectorRecordingStatusChangedNotification"), object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "screenRecordingDetectorRecordingStatusChangedNotification"), object: nil)
    }
    
    @objc private func setupProtectingLayer() {
        let detector = ScreenRecordingDetector.shared
        if detector.isRecording() {
            contentProtectingLayer.backgroundColor = .red
            screenRecordingStatusLabel.text = "螢幕錄影中"
        } else {
            contentProtectingLayer.backgroundColor = .clear
            screenRecordingStatusLabel.text = "螢幕未錄影(預設)"
        }
    }
}

