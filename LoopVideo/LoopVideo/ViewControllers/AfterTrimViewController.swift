//
//  AfterTrimViewController.swift
//  LoopVideo
//
//  Created by hend elsisi on 1/23/17.
//  Copyright © 2017 Minas Kamel. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Photos

enum PlayState {
    case play, pause
}

class AfterTrimViewController: UIViewController, UIScrollViewDelegate {

    var AssetGridThumbnailSize = CGSize.zero
    let frameImageWidth : CGFloat = 65
    let frameImageHeight : CGFloat = 40
    let timerStep = 0.1
    var shownFramesImagesCount : Int!
    var filterNameArray = [Any]()
   // var videoAsset : PHAsset!
    var tempVideo:AVAsset?
    var framesImages : [UIImage]!
    fileprivate var playState : PlayState = .pause
    fileprivate var playerItem : AVPlayerItem!
    fileprivate var player : AVPlayer!
    fileprivate var timer : Timer?
    var initialView:Bool = true
    @IBOutlet var playButton: UIButton!
    @IBOutlet var videoView: UIView!
    @IBOutlet var elapsedTimeLabel: UILabel!
    @IBOutlet var remainingTimeLabel: UILabel!
   // @IBOutlet var framesParentView: UIView!
    @IBOutlet var sliderView: UIView!
    @IBOutlet var framesScrollView: UIScrollView!
    var beginPrepare:Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        
        let scale: CGFloat = UIScreen.main.scale
        AssetGridThumbnailSize = CGSize.init(width: 7 * scale, height: 15 * scale)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initalizeViewsAndData()
        
       // if self.tempVideo != nil{
            self.prepareVideoAndUpdateViewsForTemp()
//        }
//        else{
//            prepareVideoAndUpdateViews(videoAsset)
//        }
    }

    func prepareVideoAndUpdateViewsForTemp(){
        DispatchQueue.main.async {
            self.playerItem = AVPlayerItem(asset: self.tempVideo!)
            self.updateViewsAfterVideoIsReady()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
        player.pause()
    }
    
    // MARK: - Screen Initialization
    fileprivate func initalizeViewsAndData() {
        playButton.isEnabled = false
        elapsedTimeLabel.text = "00:00"
        remainingTimeLabel.text = "00:00"
    }
    
    fileprivate func prepareVideoAndUpdateViews(_ asset : PHAsset) {
        
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        // else{
        PHImageManager.default().requestPlayerItem(forVideo: asset, options: options, resultHandler: { playerItem, info in
            guard playerItem != nil else { fatalError("can't get player item: \(info)") }
            DispatchQueue.main.async {
                self.playerItem = playerItem
                self.updateViewsAfterVideoIsReady()
            }
        }
        )
    }
    
    fileprivate func updateViewsAfterVideoIsReady() {
        adjustVideoPlayer()
        adjustVideoControls()
        adjustVideoFrames()
    }
    
    fileprivate func adjustVideoPlayer() {
        player = AVPlayer(playerItem: playerItem!)
        NotificationCenter.default.addObserver(self, selector: #selector(VideoProcessingViewController.playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.videoView.bounds
        self.videoView.layer.addSublayer(playerLayer)
    }
    
    fileprivate func adjustVideoControls() {
        playButton.isEnabled = true
        elapsedTimeLabel.text = timeFormat(0)
        remainingTimeLabel.text = "" + timeFormat(Int64(getVideoDuration()))
    }
    
    fileprivate func adjustVideoFrames() {
        self.prepareView()
    }
    
    
    @IBAction func selectButtonTapped(_ sender: AnyObject) {
        
       
        VideoFramesManager.instance.delegate = self
        VideoFramesManager.instance.videoDuration = getVideoDuration()
        UIUtils.instance.showPorgressHudWithMessage("Preparing Images", view: self.view)
        
//        if (getVideoCurrentTime() == getVideoDuration() || (getVideoCurrentTime() + 10 > getVideoDuration()))
//        {
//            VideoFramesManager.instance.generateFramesPhotosFromSpecificTime(getVideoCurrentTime() - 10)
//        }
//        else
//        {
            VideoFramesManager.instance.generateFramesPhotosFromSpecificTime(getVideoCurrentTime())
            print("time \(getVideoCurrentTime())")
       // }
    }
    
    @IBAction func playButtonTapped(_ sender: AnyObject) {
        switch playState {
        case .play:
            pause()
            break
        case .pause:
            play()
            break
        }
    }
    
    
    @IBAction func minusHalfSecondButtonTapped(_ sender: AnyObject) {
        scrollManualButtonsTapped(-0.5)
    }
    
    @IBAction func plusHalfSecondButtonTapped(_ sender: AnyObject) {
        scrollManualButtonsTapped(0.5)
    }
    
    @IBAction func minusDeciSecondButtonTapped(_ sender: AnyObject) {
        scrollManualButtonsTapped(-0.1)
    }
    
    @IBAction func plusDeciSecondButtonTapped(_ sender: AnyObject) {
        scrollManualButtonsTapped(0.1)
    }
    
    //MARK: - Frames Scroll View
    func changeScrollViewOffsetXPosition(byOffset offset : CGFloat)  {
        let currentOffset = self.framesScrollView.contentOffset
        var newXPosition = currentOffset.x + (self.frameImageWidth * offset)
        newXPosition = max(0, min(newXPosition , CGFloat(self.shownFramesImagesCount) * self.frameImageWidth))
        let newOffset = CGPoint(x: newXPosition , y: currentOffset.y)
        self.framesScrollView.delegate = nil
        self.framesScrollView.setContentOffset(newOffset, animated: false)
        self.framesScrollView.delegate = self
    }
    
    func scrollManualButtonsTapped(_ offset : CGFloat) {
        DispatchQueue.main.async {
            self.changeScrollViewOffsetXPosition(byOffset: offset)
            let newOffset = self.framesScrollView.contentOffset
            self.updateVideoPlayerAfterScrolling(Double(newOffset.x / self.frameImageWidth))
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset
        updateVideoPlayerAfterScrolling(Double(currentOffset.x / frameImageWidth))
    }
    
    //MARK: - Video Play utility methods
    fileprivate func play() {
        playButton.setTitle("Pause", for: UIControlState())
        playState = .play
        player.play()
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: timerStep, target: self, selector: #selector(VideoProcessingViewController.updateTime(_:)), userInfo: nil, repeats: true)
        timer!.fire()
    }
    
    fileprivate func pause() {
        timer?.invalidate()
        playButton.setTitle("Play", for: UIControlState())
        playState = .pause
        player.pause()
    }
    
    func playerDidFinishPlaying() {
        pause()
    }
    
    func updateTime(_ isScrolling : Bool) {
        let currentTime = getVideoCurrentTime()
        let videoDuration = getVideoDuration()
        let remaining = Int(videoDuration) - Int(currentTime)
        elapsedTimeLabel.text = timeFormat(Int64(currentTime))
      remainingTimeLabel.text = "" + timeFormat(Int64(remaining))
        if (!isScrolling) {
            DispatchQueue.main.async {
                self.changeScrollViewOffsetXPosition(byOffset: CGFloat(self.timerStep))
            }
        }
    }
    
    func updateVideoPlayerAfterScrolling(_ timeToSeek : Double) {
        let videoDuration = Double(getVideoDuration())
        let newTime = timeToSeek < videoDuration ? timeToSeek : videoDuration
        let timeScale = player.currentItem?.asset.duration.timescale ?? 60000
        
        player.isMuted = true
        player.seek(to: CMTime(seconds: newTime, preferredTimescale: timeScale), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (finished) in
            if finished {
                self.updateTime(true)
                self.player.isMuted = false
            }
        })
    }
    
    //MARK: - Video Time utility methods
    fileprivate func getVideoDuration() -> Double {
      //  if self.tempVideo != nil{
            return self.tempVideo!.duration.seconds
//        }
//        else{
//            return videoAsset.duration
//        }
    }
    
    fileprivate func getVideoCurrentTime() -> Double {
        return CMTimeGetSeconds(playerItem.currentTime())
    }
    
    fileprivate func timeFormat(_ value : Int64) -> (String)
    {
        let minutes : Int = Int(value / 60)
        let seconds : Int = Int(value - (minutes * 60))
        return NSString(format: "%d:%02d", minutes, seconds) as (String)
    }
    
    func prepareView(){
        var imagesViews = [UIImageView]()
        let scrollViewWidth = framesScrollView.frame.size.width
        let scrollViewStartEndOffsets = scrollViewWidth / 2
        //  let scrollViewStartEndOffsets = CGFloat(0)
        if framesImages.count > 0 {
            shownFramesImagesCount = framesImages.count / VideoFramesManager.requiredFramesForOneSecond
            for i in 0..<shownFramesImagesCount {
                let currentImageIndex = i * VideoFramesManager.requiredFramesForOneSecond
                let imageView = UIImageView(image: framesImages[currentImageIndex])
                let xPosition : CGFloat = scrollViewStartEndOffsets + frameImageWidth * CGFloat(i)
                imageView.frame = CGRect(x: xPosition, y: 0, width: frameImageWidth, height: frameImageHeight)
                imagesViews.append(imageView)
            }
            
            DispatchQueue.main.async(execute: {
                
                for imageView in imagesViews {
                    self.framesScrollView.addSubview(imageView)
                }
                self.framesScrollView.setNeedsLayout()
                self.framesScrollView.contentSize = CGSize(width: scrollViewWidth + (CGFloat(self.shownFramesImagesCount) * self.frameImageWidth), height: self.frameImageHeight)
                //  UIUtils.instance.hideProgressHud()
                self.beginPrepare = false
            })
        }
    }

}

// MARK: - Extensions
extension AfterTrimViewController : VideoFramesManagerDelegate {
    func videoFramesAreReady(_ images: [UIImage]) {
        
        DispatchQueue.main.async {
            print("no need")
        }
    }
    func videoImagesAreReady(_ images: [UIImage])
    {
       print("come")
        DispatchQueue.main.async(execute: {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let imgDisplayerViewController: ImageDisplayerViewController = storyBoard.instantiateViewController(withIdentifier: "ImageDisplayer") as! ImageDisplayerViewController
            imgDisplayerViewController.images = images
            
            if self.getVideoDuration() < 10 {
                if self.getVideoCurrentTime() == self.getVideoDuration() || self.getVideoCurrentTime() + 3 > self.getVideoDuration() && self.getVideoCurrentTime() != 0
                {
                    imgDisplayerViewController.startTime = CGFloat(self.getVideoCurrentTime() - 3)
                }
                else{

                    imgDisplayerViewController.startTime = CGFloat(self.getVideoCurrentTime())
                }
            }
            else{
                
                if self.getVideoCurrentTime() == self.getVideoDuration() || self.getVideoCurrentTime() + 9 > self.getVideoDuration() && self.getVideoCurrentTime() != 0
                {
                    imgDisplayerViewController.startTime = CGFloat(self.getVideoCurrentTime() - 9)
                }
                else{
                    imgDisplayerViewController.startTime = CGFloat(self.getVideoCurrentTime())
                }
            }            
            imgDisplayerViewController.videoAssetBeforeSave = self.tempVideo
            imgDisplayerViewController.videoDuration = self.getVideoDuration()
            self.navigationController?.pushViewController(imgDisplayerViewController, animated: true)
            UIUtils.instance.hideProgressHud()
        })
        
    }
    
}
