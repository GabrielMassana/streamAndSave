//
//  ViewController.swift
//  streamAndSave
//
//  Created by GabrielMassana on 02/06/2016.
//  Copyright © 2016 GabrielMassana. All rights reserved.
//

import UIKit

import AVFoundation

class ViewController: UIViewController {
    
    //MARK: - Accessors
    
    private var context = 0

    lazy var spinnerView: SpinnerView = {
       
        var spinnerView = SpinnerView()
        
        spinnerView.frame = UIScreen.mainScreen().bounds
        spinnerView.spinner.center = self.view.center

        return spinnerView
    }()
    
    lazy var player: AVPlayer = {
        
        var player: AVPlayer = AVPlayer(playerItem: self.playerItem)
        
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        
        return player
    }()
    
    lazy var playerItem: AVPlayerItem = {
        
        var playerItem: AVPlayerItem = AVPlayerItem(asset: self.asset)
        
        return playerItem
    }()
    
    lazy var asset: AVURLAsset = {
        
        var asset: AVURLAsset = AVURLAsset(URL: self.url)
        
        asset.resourceLoader.setDelegate(self, queue: dispatch_get_main_queue())
        
        return asset
    }()
    
    lazy var playerLayer: AVPlayerLayer = {
        
        var playerLayer: AVPlayerLayer = AVPlayerLayer(player: self.player)
        
        playerLayer.frame = UIScreen.mainScreen().bounds
        playerLayer.backgroundColor = UIColor.clearColor().CGColor
        
        return playerLayer
    }()
    
    var url: NSURL = {
        
        var url = NSURL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        
        return url!
    }()
    
    //MARK: - Init

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder:aDecoder)
        
        playerItem.addObserver(self, forKeyPath: "status", options: .New, context: &context)
    }
    
    //MARK: - ViewLifeCycle

    override func viewDidLoad() {
        
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)

        view.layer.addSublayer(playerLayer)
        view.addSubview(spinnerView)

        player.play()
    }
    
    //MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if context == &self.context {
            
            if let object = object {
                
                if object.isKindOfClass(AVPlayerItem.self) {
                    
                    let item = object as! AVPlayerItem
                    
                    switch item.status {
                        
                    case .Failed:
                        
                        print("Failed")
                        
                    case .ReadyToPlay:
                        
                        print("ReadyToPlay")
                        
                        spinnerView.removeFromSuperview()
                        
                    case .Unknown:
                        
                        print("Unknown")
                    }
                }
            }
        }
    }
    
    //MARK: - Notifications

    func playerItemDidReachEnd(notification: NSNotification) {
        
        if notification.object as? AVPlayerItem  == player.currentItem {
            
            player.pause()
            player.seekToTime(kCMTimeZero)
            player.play()
            
            /*--------------------*/

            let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
            
            let filename = "filename.mp4"
            
            let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last!

            let outputURL = documentsDirectory.URLByAppendingPathComponent(filename)
            
            exporter?.outputURL = outputURL
            exporter?.outputFileType = AVFileTypeMPEG4
            
            exporter?.exportAsynchronouslyWithCompletionHandler({
                
                print(exporter?.status.rawValue)
                print(exporter?.error)
            })
        }
    }
    
    //MARK: - Deinit

    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        playerItem.removeObserver(self, forKeyPath: "status", context: &context)
    }
}

extension ViewController : AVAssetResourceLoaderDelegate {

}
