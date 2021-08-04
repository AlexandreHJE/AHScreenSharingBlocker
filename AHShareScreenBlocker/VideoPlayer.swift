//
//  VideoPlayer.swift
//  BlockScreenShotDemo
//
//  Created by Alex Hu on 2021/4/28.
//

import AVFoundation
import AVKit
import UIKit

class VideoPlayer: NSObject {
    private var urlAsset: AVURLAsset?
    private var playerItem: AVPlayerItem?
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    private weak var containerView: UIView?
    private var videoLoader: VideoResourceLoaderDelegate?

    func playURL(url: String, inView container: UIView?) {
        if url.count == 0 { return }
        if container == nil { return }
        containerView = container
        urlAsset = AVURLAsset(url: URL(string: url)!, options: nil)
        videoLoader = VideoResourceLoaderDelegate()
        urlAsset?.resourceLoader.setDelegate(videoLoader, queue: DispatchQueue.main)
//        playerItem = AVPlayerItem(asset: urlAsset!)
        setPlayerItem(item: AVPlayerItem(asset: urlAsset!))
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = CGRect(x: 0, y: 0, width: container?.bounds.size.width ?? 100, height: (container?.bounds.size.height ?? 10) - 1)
    }

    func resume() {
        guard playerItem != nil else { return }
        player?.play()
    }

    func pause() {
        guard playerItem != nil else { return }
        player?.pause()
    }

    func stop() {
        guard playerItem != nil else { return }
        guard player != nil else { return }
        player?.pause()
        player?.cancelPendingPrerolls()
        if playerLayer != nil {
            playerLayer?.removeFromSuperlayer()
            playerLayer = nil
        }
        urlAsset?.resourceLoader.setDelegate(nil, queue: DispatchQueue.main)
        urlAsset = nil
        playerItem = nil
        player = nil
    }

    func handleShowViewSublayers() {
        if let subviews = containerView?.subviews {
            subviews.forEach { $0.removeFromSuperview() }
        }
        containerView?.layer.addSublayer(playerLayer!)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            guard let itemObject = object as? AVPlayerItem else { return }
            playerItem = itemObject
            switch playerItem?.status {
            case .unknown:
                print("unknown")
                break
                
            case .readyToPlay:
                player?.play()
                handleShowViewSublayers()
                print("duration: \(duration())")
                
            case .failed:
                print("failed")
                break
                
            default:
                break
            }
        } else if keyPath == "playbackBufferEmpty" {
            
        } else if keyPath == "playbackLikelyToKeepUp" {
            
        }
    }

    func duration() -> CGFloat {
        let duration: CGFloat = CGFloat(CMTimeGetSeconds(playerItem?.asset.duration ?? CMTime(seconds: 0.0, preferredTimescale: 600)))
        return duration
    }

    func setPlayerItem(item: AVPlayerItem) {
        if let playerItem = playerItem {
            playerItem.removeObserver(self, forKeyPath: "status")
            playerItem.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            playerItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        }

        playerItem = item
        playerItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: NSKeyValueObservingOptions.new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.new, context: nil)
    }

    func setPlayerLayer(layer: AVPlayerLayer) {
        if let playerLayer = playerLayer {
            playerLayer.removeFromSuperlayer()
        }
        playerLayer = layer
    }
}

class VideoResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        let url = loadingRequest.request.url?.absoluteString
        if let urlString = url, urlString == "jedi://text.m3u8" {
            let data = m3u8Generator(fileString: "text").data(using: .utf8)
            loadingRequest.dataRequest?.respond(with: data!)
            loadingRequest.finishLoading()

        } else if let urlString = url, urlString == "jedi://test2.m3u8" {
            let data = m3u8Generator(fileString: "test2").data(using: .utf8)
            loadingRequest.dataRequest?.respond(with: data!)
            loadingRequest.finishLoading()

        } else if let urlString = url, urlString == "jedi://text.key" {
            let data = NSMutableData(length: 16)
            data?.resetBytes(in: NSMakeRange(0, (data?.length)!))
            loadingRequest.dataRequest?.respond(with: data! as Data)
            loadingRequest.finishLoading()
        }
        
        return true
    }

    func m3u8Generator(fileString: String) -> String {
        let format = """
        #EXTM3U
        #EXT-X-PLAYLIST-TYPE:VOD
        #EXT-X-VERSION:5
        #EXT-X-TARGETDURATION:%@
        #EXT-X-KEY:METHOD=SAMPLE-AES,URI=\"jedi://text.key\"
        #EXTINF:%@,
        http://localhost:%@
        #EXT-X-ENDLIST
        """

        let duration = "1"
        let EXTINF = "0.066667"
        let port = "8989"
        let host = String(format: "%@/\(fileString).mp4", port)
        let res = String(format: format, duration, EXTINF, host)

        return res
    }
}
