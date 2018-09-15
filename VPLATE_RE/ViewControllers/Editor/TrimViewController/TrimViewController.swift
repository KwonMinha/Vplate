//
//  TrimViewController.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 31..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import PryntTrimmerView
import BMPlayer


class TrimViewController: ViewController {
    @IBOutlet weak var playerView: Player!
    @IBOutlet weak var trimmerView: TrimmerView!
    @IBOutlet weak var durationButton: DesignableButton!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    var asset: AVAsset?
    var duration: Double = 15
    var delegate: PopToEditorVCDelegate?
    var fileName: String!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.shouldRotate = false
        self.setUpViewController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.playerView.delegate = self
        self.trimmerView.delegate = self
        self.trimmerView.asset = asset
        if let startSec = self.trimmerView.startTime?.seconds , let endSec = self.trimmerView.endTime?.seconds {
            self.startLabel.text = "\(Int(round(startSec)))sec"
            self.endLabel.text = "\(Int(round(endSec)))sec"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.playerView.pause()
    }
    
    override func setUpViewController() {
        self.navigationItem.title = "Clip Length".localized
        
        BMPlayerConf.topBarShowInCase = BMPlayerTopBarShowCase.none
        BMPlayerConf.enablePlaytimeGestures = false
        if(duration == 0) {
            duration = 15
        }
        
        self.trimmerView.minDuration = duration
        self.trimmerView.maxDuration = duration
        guard let asset = self.asset else {return}
        self.addVideoPlayer(with: asset, playerView: playerView)
        
        self.durationButton.setTitle("Total Length"+": \(Int(duration))"+"Seconds".localized, for: .normal)
        self.durationButton.isUserInteractionEnabled = false
        
        
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Done".localized, style: .plain, target: self, action: #selector(trim)), animated: true)
    }
    
    private func addVideoPlayer(with asset: AVAsset, playerView: BMPlayer) {
        guard let urlAsset = asset as? AVURLAsset else {return}
        playerView.setVideo(resource: BMPlayerResource(url: urlAsset.url))
        if let item = playerView.avPlayer?.currentItem {
            NotificationCenter.default.addObserver(self, selector: #selector(TrimViewController.itemDidFinishPlaying(_:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        }
        self.playerView.isMuted(true)
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        if let startTime = trimmerView.startTime {
            playerView.seek(startTime.seconds)
        }
    }
    
    func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                        selector:
            #selector(TrimViewController.onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    
    func stopPlaybackTimeChecker() {
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    @objc func onPlaybackTimeChecker() {
        
        guard let startTime = trimmerView.startTime, let endTime = trimmerView.endTime else { return }
        
        if let playBackTime = playerView.avPlayer?.currentTime() {
            trimmerView.seek(to: playBackTime)
            if playBackTime >= endTime {
                playerView.seek(startTime.seconds)
                trimmerView.seek(to: startTime)
            }
        }
    }
    
    @objc func trim() {
        self.playerView.pause()
        guard let folderURL = URL.createFolder(folderName: "VPALTE") else {return}
        let filePath = folderURL.appendingPathComponent(fileName, isDirectory: false)
        let videoTrack:AVAssetTrack = asset!.tracks(withMediaType: AVMediaType.video)[0]
        let videoTrackSize = videoTrack.naturalSize
        var t = videoTrack.preferredTransform
  
        //        let heightScale = CGFloat(self.videoRenderSize.height / videoTrackSize.height)
        //        let widthScale = CGFloat(self.videoRenderSize.width / videoTrackSize.width)
        //
        //        layerInstruction.setTransform(CGAffineTransformMakeScale(widthScale,heightScale), atTime: instruction.timeRange.start)
        //
        //        break
        //        default:
        //        print("Unknown Orientation")
        //    }
        //
        //    instruction.layerInstructions = [layerInstruction]
        //    compositionInstructions.append(instruction)
        //}
        //
        //videoComposition.instructions = compositionInstructions
        //videoComposition.renderSize = self.videoRenderSize
        //videoComposition.frameDuration = CMTimeMake(1, 30)
        //videoComposition.renderScale = 1.0 // This is a iPhone only option.
        
        
        
        if t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0
        {
            t.a = 1.0
            t.b = 0.0
            t.c = 0.0
            t.d = 1.0
            t.tx = 0.0
        }
        
        guard let urlAsset = asset as? AVURLAsset else {return}
        
        
        guard let startTime = self.trimmerView.startTime else {return}
        guard let endTime = self.trimmerView.endTime else {return}
        VideoTrimmer().trimVideo(sourceURL: urlAsset.url,
                                 destinationURL: filePath,
                                 trimPoints: [ (startTime, endTime) ]) { (err, videoURL) in
                                    if let err = err {
                                        print(err.localizedDescription)
                                        return
                                    }
                                    DispatchQueue.main.async {
                                        self.navigationController?.popViewController(animated: true)
                                        if let videoURL = videoURL {
                                            self.delegate?.popAction(imageURL: nil, videoURL: videoURL)
                                        }
                                        
                                    }
                                    
        }
    }
}

extension TrimViewController: TrimmerViewDelegate, BMPlayerDelegate {
    func bmPlayer(player: BMPlayer, playerStateDidChange state: BMPlayerState) {
        
    }
    
    func bmPlayer(player: BMPlayer, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {
        
    }
    
    func bmPlayer(player: BMPlayer, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
        if ceil(currentTime) < round(trimmerView.startTime!.seconds) || round(trimmerView.endTime!.seconds) < floor(currentTime) {
            playerView.seek(trimmerView.startTime!.seconds)
            playerView.play()
            startPlaybackTimeChecker()
        }
    }
    
    func bmPlayer(player: BMPlayer, playerIsPlaying playing: Bool) {
        if !playing {
            startPlaybackTimeChecker()
        }
        else {
            stopPlaybackTimeChecker()
        }
    }
    
    func bmPlayer(player: BMPlayer, playerOrientChanged isFullscreen: Bool) {
        
    }
    
    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        playerView.pause()
        playerView.seek(playerTime.seconds)
        let duration = (trimmerView.endTime! - trimmerView.startTime!).seconds
        
        if let startSec = self.trimmerView.startTime?.seconds , let endSec = self.trimmerView.endTime?.seconds {
            self.startLabel.text = "\(Int(round(startSec)))" + "Seconds".localized
            self.endLabel.text = "\(Int(round(endSec)))" + "Seconds".localized
        }
    }
    
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        playerView.seek(playerTime.seconds)
        playerView.play()
        startPlaybackTimeChecker()
    }
    
}
