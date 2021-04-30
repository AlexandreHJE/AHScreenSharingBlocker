//
//  VideoPlayer.swift
//  BlockScreenShotDemo
//
//  Created by Alex Hu on 2021/4/28.
//

import AVFoundation
import AVKit
import UIKit

class VideoPlayer {
//    lazy var urlAsset: AVURLAsset = {
//        let urlAsset = AVURLAsset(url: URL(string: "")!)
//
//        return urlAsset
//    } ()
//    lazy var playerItem: AVPlayerItem = {
//        let item = AVPlayerItem(asset: urlAsset)
//
//        return item
//    } ()
    
    private var urlAsset: AVURLAsset?
    private var playerItem: AVPlayerItem?
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    private weak var containerView: UIView?
    
    
}

//NSString *url = loadingRequest.request.URL.absoluteString;
//    if ([url isEqualToString:@"jedi://text.m3u8"]) {
//        NSData *data = [[self gen_m3u8] dataUsingEncoding:NSUTF8StringEncoding];
//        [loadingRequest.dataRequest respondWithData:data];
//        [loadingRequest finishLoading];
//    }
//    else if([url isEqualToString:@"jedi://text.key"]) {
//        NSMutableData *data = [NSMutableData dataWithLength:16];
//        [data resetBytesInRange:NSMakeRange(0, [data length])];
//        [loadingRequest.dataRequest respondWithData:data];
//        [loadingRequest finishLoading];
//    }
//
//    return YES;

class VideoResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        let url = loadingRequest.request.url?.absoluteString
        if let urlString = url, urlString == "jedi://text.m3u8" {
            let data = m3u8Generator().data(using: .utf8)
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
    
    func m3u8Generator() -> String {
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
        let host = String(format: "%@/text", port)
        let res = String(format: format, duration, EXTINF, host)

        return res
    }
}
