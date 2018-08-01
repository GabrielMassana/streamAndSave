//
//  ViewController.swift
//  streamAndSave
//
//  Created by GabrielMassana on 02/06/2016.
//  Copyright © 2016 GabrielMassana. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    //MARK: - Accessors
    
    private var context = 0

    lazy var spinnerView: SpinnerView = {
        var spinnerView = SpinnerView()
        spinnerView.frame = UIScreen.main.bounds
        spinnerView.spinner.center = self.view.center
        return spinnerView
    }()
    
    lazy var player: AVPlayer = {
        var player: AVPlayer = AVPlayer(playerItem: self.playerItem)
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        return player
    }()
    
    lazy var playerItem: AVPlayerItem = {
        var playerItem: AVPlayerItem = AVPlayerItem(asset: self.asset)
        return playerItem
    }()
    
    lazy var asset: AVURLAsset = {
        var asset: AVURLAsset = AVURLAsset(url: self.url as URL)
        asset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
        return asset
    }()
    
    lazy var playerLayer: AVPlayerLayer = {
        var playerLayer: AVPlayerLayer = AVPlayerLayer(player: self.player)
        playerLayer.frame = UIScreen.main.bounds
        playerLayer.backgroundColor = UIColor.clear.cgColor
        return playerLayer
    }()
    
    var url: NSURL = {
        
        var url = NSURL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        return url!
        
    }()
    
    lazy var resumeButton: UIButton = {
       
        var resumeButton = UIButton(type: .custom)
        
        resumeButton.frame = CGRect(x:0, y:20, width:UIScreen.main.bounds.width, height:70)
        resumeButton.setTitle("Resume Play", for: .normal)
        resumeButton.setTitleColor(UIColor.black, for: .normal)
        resumeButton.addTarget(self, action: #selector(resumeButtonPressed), for: .touchUpInside)
        resumeButton.isHidden = true
        resumeButton.backgroundColor = UIColor.lightGray
        
        return resumeButton
    }()
    
    //MARK: - Init
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder:aDecoder)
        
        playerItem.addObserver(self, forKeyPath: "status", options: .new, context: &context)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemPlaybackStalled), name: .AVPlayerItemPlaybackStalled, object: nil)

    }
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        
        super.viewDidLoad()

        view.layer.addSublayer(playerLayer)
        view.addSubview(spinnerView)
        view.addSubview(resumeButton)
        player.play()
        
    }
    
    //MARK: - ButtonActions
    @objc func resumeButtonPressed() {
        resumeButton.isHidden = true
        player.play()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let key = keyPath {
            if key == "status" {
                if self.playerItem == (object as? AVPlayerItem) {
                
                    let item = object as! AVPlayerItem
                    switch item.status {
                        
                    case .failed:
                        ()
                        
                    case .readyToPlay:
                        spinnerView.removeFromSuperview()
                        
                    case .unknown:
                        ()
                        
                    }
                }
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    //MARK: - Notifications
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        
        if notification.object as? AVPlayerItem  == player.currentItem {
            
            player.pause()
            player.seek(to: kCMTimeZero)
            player.play()
            
            /*--------------------*/
            let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
            let filename = self.url.lastPathComponent
            
            let documentsDirectory = getDocumentsDirectory()
            let outputURL = documentsDirectory.appendingPathComponent(filename!)
            
            exporter?.outputURL = outputURL
            exporter?.outputFileType = AVFileType.mp4
            
            exporter?.exportAsynchronously(completionHandler: {
                
                print(exporter?.status.rawValue ?? 0)
                print(exporter?.error ?? "no error, file saved sucessfully to \(outputURL)")
            })
        }
    }
    
    @objc func playerItemPlaybackStalled(notification: NSNotification) {
        player.pause()
        resumeButton.isHidden = false
    }
    
    //MARK: - Deinit

    deinit {
        
        NotificationCenter.default.removeObserver(self)
        playerItem.removeObserver(self, forKeyPath: "status", context: &context)
    }
}

extension ViewController : AVAssetResourceLoaderDelegate {

}
