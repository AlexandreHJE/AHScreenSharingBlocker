//
//  ViewController.swift
//  BlockScreenShotDemo
//
//  Created by Alex Hu on 2021/4/28.
//

import UIKit
import GCDWebServer
import Alamofire

class ViewController: UIViewController {
    @IBOutlet weak var screenRecordingStatusLabel: UILabel!
    @IBOutlet weak var protectedContentLabel: UILabel!
    @IBOutlet weak var contentProtectingLayer: UIView!
    @IBOutlet weak var playerContainerView: UIView!
    var webserver: GCDWebServer?
    var player: VideoPlayer?
    let videoURL: String = "https://o2tube-test.s3-ap-northeast-1.amazonaws.com/videos/995f2934test2.mp4"
    let fm = FileManager.default

    func getMP4FileFromURL(urlString: String) {
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = docsUrl.appendingPathComponent("test2.mp4")
        print("docsURL: \(docsUrl)")
        let directory = "\(NSHomeDirectory())/tmp/www"
        let toPath = "\(directory)/test2.mp4"
        print(toPath)
        try? fm.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        if fm.fileExists(atPath: toPath) {
            print("影片已經下載")
            startWebserver()
            return
        } else {
            var request = URLRequest(url: URL(string: videoURL)!)
            request.httpMethod = "GET"
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            session.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    print("URL Data task error occured")
                    return
                }
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        DispatchQueue.main.async {
                            if let data = data {
                                if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic) {
                                    print("url data written...")
                                    self.startWebserver()
                                } else {
                                    print("url data written error occured")
                                }
                            }
                        }
                    }
                }
            }.resume()
        }

    }

    func startWebserver() {
        webserver = GCDWebServer()
        let directory = "\(NSHomeDirectory())/tmp/www"
        print(directory)
        try? fm.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        let toPath = "\(directory)/test2.mp4"
        if fm.fileExists(atPath: toPath) {
            try? fm.removeItem(atPath: toPath)
        }
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destUrlString = "\(NSHomeDirectory())/Documents/test2.mp4"
        do {
            try fm.copyItem(atPath: destUrlString, toPath: toPath)
        } catch {
            print("copied item error: \(error)")
        }
        webserver?.addGETHandler(forBasePath: "/", directoryPath: directory, indexFilename: nil, cacheAge: 3600, allowRangeRequests: true)
        webserver?.start(withPort: 8989, bonjourName: nil)
        startPlayer()
    }

    func startPlayer() {
        player = VideoPlayer()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.25) {
            self.player?.playURL(url: "jedi://test2.m3u8", inView: self.playerContainerView)
            self.player?.resume()
            print("player")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        getMP4FileFromURL(urlString: videoURL)

//        webserver = GCDWebServer()
//        let directory = "\(NSHomeDirectory())/tmp/www"
//        print(directory)

//        try? fm.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
//        let path = Bundle.main.path(forResource: "text", ofType: "mp4")
//        let toPath = "\(directory)/text.mp4"
//        let toPath = "\(directory)/995f2934test2.mp4"
//        if fm.fileExists(atPath: toPath) {
//            try? fm.removeItem(atPath: toPath)
//        }
//        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let destinationUrl = docsUrl.appendingPathComponent("995f2934test2.mp4")
//        do {
//            try fm.copyItem(atPath: destinationUrl.absoluteString, toPath: toPath)
//        } catch {
//            print(error)
//        }
//        webserver?.addGETHandler(forBasePath: "/", directoryPath: directory, indexFilename: nil, cacheAge: 3600, allowRangeRequests: true)
//        webserver?.start(withPort: 8989, bonjourName: nil)
//        player = VideoPlayer()
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.25) {
////            self.player?.playURL(url: "http://localhost:8989/text.mp4", inView: self.playerContainerView)
//            self.player?.playURL(url: "jedi://text.m3u8", inView: self.playerContainerView)
//            self.player?.resume()
//            print("player")
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(setupProtectingLayer), name: NSNotification.Name(rawValue: "screenRecordingDetectorRecordingStatusChangedNotification"), object: nil)
        ScreenRecordingDetector.shared.triggerDetectorTimer()
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
