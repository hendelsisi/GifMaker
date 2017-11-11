//
//  VideoProcessingViewController.swift
//  LoopVideo
//
//  Created by Minas Kamel on 9/18/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Photos



class VideoProcessingViewController: UIViewController, UIScrollViewDelegate {
    
    var startTrimPoint :Double = 0
    var endTrimPoint :Double = 0
    var interrupt:Bool = false
     var beginImpotVideo:Bool = false
    var window:UIView!
    var videoAfterTrim:AVAsset?
    @IBOutlet weak var hereEndLabel: UILabel!
    @IBOutlet weak var hereStartLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    
    
    @IBAction func theTrimPress(_ sender: AnyObject) {
        print("start :  \(startTrimPoint)")
        print("end  : \(endTrimPoint)")
        if startTrimPoint != endTrimPoint && endTrimPoint > startTrimPoint
            && endTrimPoint - startTrimPoint >= 2
        {
           // self.saveAsVideo() //go to aftertrimscreen
            self.goAfterTrimScreen()
        }
        else{
            var message = "Please select Trim with minimum duration two seconds"
            let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                UIAlertAction in
                NSLog("OK Pressed")
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
   
    let indicatorWidth: CGFloat = 20.0
    var currentEndX:CGFloat = 0
    var currentStartX:CGFloat = 0
    
    let topBorderHeight: CGFloat      = 5
    var startIndicator      = ABStartIndicator()
    var endIndicator        = ABEndIndicator()
    var topLine             = ABBorder()
    var bottomLine          = ABBorder()
    let bottomBorderHeight: CGFloat   = 5
    
    var AssetGridThumbnailSize = CGSize.zero
    let frameImageWidth : CGFloat = 65
    var frameImageHeight : CGFloat = 65
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
    @IBOutlet var framesParentView: UIView!
    @IBOutlet var sliderView: UIView!
    @IBOutlet var framesScrollView: UIScrollView!
    
    @IBOutlet weak var startLabel: UILabel!
    
    @IBOutlet weak var endLabel: UILabel!
    
    //MARK: Window method
    
    func drawWindow( view:UIView){
        startIndicator = ABStartIndicator(frame: CGRect(x: -indicatorWidth ,
                                                        y: -topBorderHeight,
                                                        width: 20,
                                                        height: view.bounds.size.height + bottomBorderHeight + topBorderHeight))
        startIndicator.layer.anchorPoint = CGPoint(x: 1, y: 0.5)
        view.addSubview(startIndicator)
        
        currentStartX = -indicatorWidth
        
        endIndicator = ABEndIndicator(frame: CGRect(x: view.bounds.width - indicatorWidth ,
                                                    y: -topBorderHeight,
                                                    width: indicatorWidth,
                                                    height: view.bounds.size.height + bottomBorderHeight + topBorderHeight))
       currentEndX = view.bounds.width - indicatorWidth
        endIndicator.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        view.addSubview(endIndicator)
        
        topLine = ABBorder(frame: CGRect(x: -indicatorWidth ,
                                         y: -topBorderHeight,
                                         width: view.bounds.width + self.sliderView.frame.width/2 ,
                                         height: topBorderHeight))
        view.addSubview(topLine)
        
        bottomLine = ABBorder(frame: CGRect(x: -indicatorWidth ,
                                            y: view.bounds.size.height - bottomBorderHeight ,
                                            width: view.bounds.width + self.sliderView.frame.width/2 ,
                                            height: bottomBorderHeight))
        view.addSubview(bottomLine)
        print(" height \( view.bounds.size.height)")
        
    }
    
  func  trimStart(startNewValue: CGFloat){
    
    let subViews = self.window.subviews
    for subview in subViews{
        
        subview.removeFromSuperview()
    }
    
    startIndicator = ABStartIndicator(frame: CGRect(x: startNewValue - indicatorWidth,
                                                    y: -topBorderHeight,
                                                    width: 20,
                                                    height: self.window.bounds.size.height + bottomBorderHeight + topBorderHeight))
    startIndicator.layer.anchorPoint = CGPoint(x: 1, y: 0.5)
    
    self.window.addSubview(startIndicator)
    currentStartX = startNewValue - indicatorWidth
    
    print("start indicator \(currentStartX)")
    endIndicator = ABEndIndicator(frame: CGRect(x: currentEndX ,
                                                y: -topBorderHeight,
                                                width: indicatorWidth,
                                                height: self.window.bounds.size.height + bottomBorderHeight + topBorderHeight))
   
    endIndicator.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
    self.window.addSubview(endIndicator)
    
    
    topLine = ABBorder(frame: CGRect(x: startNewValue - indicatorWidth,
                                     y: -topBorderHeight,
                                     width: currentEndX - currentStartX + self.sliderView.frame.width/2  ,
                                     height: topBorderHeight))
    self.window.addSubview(topLine)
   

    bottomLine = ABBorder(frame: CGRect(x: startNewValue - indicatorWidth,
                                        y: self.window.bounds.size.height - bottomBorderHeight,
                                        width: currentEndX - currentStartX  + self.sliderView.frame.width/2 ,
                                        height: bottomBorderHeight))
    self.window.addSubview(bottomLine)
    
    }
    
    func  trimeEnd(endNewValue: CGFloat){
        
        let subViews = self.window.subviews
        for subview in subViews{
            
            subview.removeFromSuperview()
        }
        
         print("start indicator from end \(currentStartX)")
        
        startIndicator = ABStartIndicator(frame: CGRect(x: currentStartX ,
                                                        y: -topBorderHeight,
                                                        width: 20,
                                                        height: self.window.bounds.size.height + bottomBorderHeight + topBorderHeight))
        startIndicator.layer.anchorPoint = CGPoint(x: 1, y: 0.5)
        self.window.addSubview(startIndicator)
      
        endIndicator = ABEndIndicator(frame: CGRect(x: endNewValue - indicatorWidth - indicatorWidth  ,
                                                    y: -topBorderHeight,
                                                    width: indicatorWidth,
                                                    height: self.window.bounds.size.height + bottomBorderHeight + topBorderHeight))
        currentEndX = endNewValue - indicatorWidth - indicatorWidth
        endIndicator.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        self.window.addSubview(endIndicator)
       
        topLine = ABBorder(frame: CGRect(x: currentStartX ,
                                         y: -topBorderHeight,
                                         width: endNewValue - self.sliderView.frame.width/2 - currentStartX   ,
                                         height: topBorderHeight))
        self.window.addSubview(topLine)
        print(" Width \(endNewValue + indicatorWidth)")
        bottomLine = ABBorder(frame: CGRect(x: currentStartX ,
                                            y: self.window.bounds.size.height - bottomBorderHeight,
                                            width: endNewValue - self.sliderView.frame.width/2 - currentStartX  ,
                                            height: bottomBorderHeight))
        self.window.addSubview(bottomLine)
        
    }
    
    
    @IBAction func startWindow(_ sender: AnyObject) {
      startTrimPoint = getVideoCurrentTime()
    
        self.trimStart(startNewValue: self.framesScrollView.contentOffset.x)
          print("the start \( getVideoCurrentTime())")
        
    }
    
    
    @IBAction func endWindow(_ sender: AnyObject) {
        endTrimPoint = getVideoCurrentTime()
        
       // currentEndX = self.framesScrollView.contentOffset.x
        print("End \(self.framesScrollView.contentOffset.x)")
        self.trimeEnd(endNewValue: self.framesScrollView.contentOffset.x)
       
         print("the end \(getVideoCurrentTime())")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.endTrimPoint = getVideoDuration()
  
        let scale: CGFloat = UIScreen.main.scale
        AssetGridThumbnailSize = CGSize.init(width: 7 * scale, height: 15 * scale)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: UIApplication.shared)
    }
    
    func appWillEnterForeground(_ notification: Notification) {
        print("appWillEnterForeground")
        DispatchQueue.main.async{
        if self.beginImpotVideo == true
        {
            UIUtils.instance.hideProgressHud()
            self.beginImpotVideo = false
        }
    }
    }
    
    func goAfterTrimScreen(){
       UIUtils.instance.showPorgressHudWithMessage("Video Next Step", view: self.view)
        
                var trime = TrimeVideo()
        
                trime.startTime = CGFloat(self.startTrimPoint)
                    trime.stopTime = CGFloat(self.endTrimPoint)
                trime.requestedAsset = self.tempVideo
                trime.trimeVideo({ (success, fpath) in
                    UIUtils.instance.hideProgressHud()
                     print("trim")
                    if success{
                        print("succes")
                        var tmpDirURL = URL(fileURLWithPath:fpath!)
                        self.videoAfterTrim = AVAsset(url:tmpDirURL)
                        VideoFramesManager.instance.delegate = self
                        VideoFramesManager.instance.extractVideoFrames(self.videoAfterTrim as! AVURLAsset)
                    }
                    else{
                         print("failed")
                        UIUtils.instance.hideProgressHud()
                        var message = "Video Failed to be saved"
                        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            NSLog("OK Pressed")}
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                })
    }
    
    func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        
        print("saved")
        UIUtils.instance.hideProgressHud()
        var message = "Video was saved"
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            NSLog("OK Pressed")
           
            self.beginImpotVideo = true
            DispatchQueue.main.async(execute: {
                UIUtils.instance.showPorgressHudWithMessage("Video Next Step", view: self.view)
            })
            VideoFramesManager.instance.delegate = self
                        PHImageManager.default().requestAVAsset(forVideo: AlbumManager.getLastAsset(), options: nil) {(avAsset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                            VideoFramesManager.instance.extractVideoFrames(avAsset as! AVURLAsset)
                        }
            
        }
        
        if let _ = error {
            title = "Error"
            message = "Video failed to save"
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    
        
       // if self.tempVideo != nil{
        self.prepareVideoAndUpdateViewsForTemp()
//        }
//        else{
//         prepareVideoAndUpdateViews(videoAsset)
//        }
    NotificationCenter.default.addObserver(self, selector: #selector(self.appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: UIApplication.shared)
    NotificationCenter.default.addObserver(self, selector: #selector(self.appdidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: UIApplication.shared)
    
    }
    
    func appdidEnterBackground(_ notification: Notification) {
        if ( beginImpotVideo == true)
        {self.interrupt = true}
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
           // }
    }

    fileprivate func updateViewsAfterVideoIsReady() {
        adjustVideoPlayer()
       // adjustVideoControls()
        adjustVideoFrames()
    }
    
    fileprivate func adjustVideoPlayer() {
        player = AVPlayer(playerItem: playerItem!)
        NotificationCenter.default.addObserver(self, selector: #selector(VideoProcessingViewController.playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.videoView.bounds
        self.videoView.layer.addSublayer(playerLayer)
    }
    
    
    fileprivate func adjustVideoFrames() {
        self.prepareView()
    }


    //MARK: - Frames Scroll View
    func changeScrollViewOffsetXPosition(byOffset offset : CGFloat)  {
        let currentOffset = self.framesScrollView.contentOffset
        if Device.isPad(){
            var newXPosition = currentOffset.x + (150 * offset)
            newXPosition = max(0, min(newXPosition , CGFloat(self.shownFramesImagesCount) * 150))
            let newOffset = CGPoint(x: newXPosition , y: currentOffset.y)
            self.framesScrollView.delegate = nil
            self.framesScrollView.setContentOffset(newOffset, animated: false)
            self.framesScrollView.delegate = self
        }
        else{
            var newXPosition = currentOffset.x + (self.frameImageWidth * offset)
            newXPosition = max(0, min(newXPosition , CGFloat(self.shownFramesImagesCount) * self.frameImageWidth))
            let newOffset = CGPoint(x: newXPosition , y: currentOffset.y)
            self.framesScrollView.delegate = nil
            self.framesScrollView.setContentOffset(newOffset, animated: false)
            self.framesScrollView.delegate = self
        }
        
    }
    
    func scrollManualButtonsTapped(_ offset : CGFloat) {
        DispatchQueue.main.async {
            self.changeScrollViewOffsetXPosition(byOffset: offset)
            let newOffset = self.framesScrollView.contentOffset
            if Device.isPad(){
             self.updateVideoPlayerAfterScrolling(Double(newOffset.x / 150))
            }
            else{
             self.updateVideoPlayerAfterScrolling(Double(newOffset.x / self.frameImageWidth))
            }
           
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset = CGPoint.init(x: scrollView.contentOffset.x, y: 0)
        if(self.framesScrollView.contentOffset.x > currentEndX )
        {
        self.deactivateStart()
        }
        else{
        self.activateStart()
        }
        if(self.framesScrollView.contentOffset.x < currentStartX){
        self.deactivateEnd()
        }
        else{
            self.activateEnd()
        }
        
        let currentOffset = scrollView.contentOffset
        if Device.isPad(){
        updateVideoPlayerAfterScrolling(Double(currentOffset.x / 150))
        }
        else{
            updateVideoPlayerAfterScrolling(Double(currentOffset.x / frameImageWidth))}
    }
    
   
    
    //MARK: - Video Play utility methods
 
    
    func playerDidFinishPlaying() {
        pause()
    }
    
    func updateTime(_ isScrolling : Bool) {
        let currentTime = getVideoCurrentTime()
        let videoDuration = getVideoDuration()
        let remaining = Int(videoDuration) - Int(currentTime)
//        elapsedTimeLabel.text = timeFormat(Int64(currentTime))
//        remainingTimeLabel.text = "" + timeFormat(Int64(remaining))
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
       // if self.tempVideo != nil{
         return self.tempVideo!.duration.seconds
//        }
//        else{
//         return videoAsset.duration
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
       
        if framesImages.count > 0 {
            shownFramesImagesCount = framesImages.count / VideoFramesManager.requiredFramesForOneSecond
            for i in 0..<shownFramesImagesCount {
                let currentImageIndex = i * VideoFramesManager.requiredFramesForOneSecond
                let imageView = UIImageView(image: framesImages[currentImageIndex])
                if Device.isPad(){
                let xPosition : CGFloat = scrollViewStartEndOffsets + 150 * CGFloat(i)
                    imageView.frame = CGRect(x: xPosition, y: 0, width: 150, height: self.framesScrollView.frame.height - 5)

                }
                else{
                  let xPosition : CGFloat = scrollViewStartEndOffsets + frameImageWidth * CGFloat(i)
                 imageView.frame = CGRect(x: xPosition, y: 0, width: frameImageWidth, height: frameImageHeight)
                }
                imagesViews.append(imageView)
            }
            
            DispatchQueue.main.async(execute: {
              
                for imageView in imagesViews {
                    self.framesScrollView.addSubview(imageView)
                    
                }
                self.framesScrollView.setNeedsLayout()
                if Device.isPad(){
                self.framesScrollView.contentSize = CGSize(width: scrollViewWidth + (CGFloat(self.shownFramesImagesCount) * 150), height: self.frameImageHeight)
                }
                else{
                self.framesScrollView.contentSize = CGSize(width: scrollViewWidth + (CGFloat(self.shownFramesImagesCount) * self.frameImageWidth), height: self.frameImageHeight)
                }
                
                if Device.isPad(){
                self.window = UIView(frame: CGRect.init(x: self.sliderView.frame.origin.x + self.sliderView.bounds.width/2 , y: 5, width: (CGFloat(self.shownFramesImagesCount) * 150) - self.sliderView.frame.width / 2, height: self.framesScrollView.frame.height - 5))
                }
                else{
                self.window = UIView(frame: CGRect.init(x: self.sliderView.frame.origin.x + self.sliderView.bounds.width/2 , y: 5, width: (CGFloat(self.shownFramesImagesCount) * self.frameImageWidth) - self.sliderView.frame.width / 2, height: self.framesScrollView.frame.height - 5))
                }
                
               
                self.window.backgroundColor = UIColor.clear
                self.framesScrollView.addSubview(self.window)
                self.drawWindow(view: self.window)
            
            })
        }
       
    }

   
    // MARK: - StartEndIndicator
    func deactivateStart(){
        self.startButton.isEnabled = false
        self.startButton.setTitleColor(UIColor.gray, for: .normal)
        self.hereStartLabel.textColor = UIColor.gray
    }
    func deactivateEnd(){
        self.endButton.isEnabled = false
        self.endButton.setTitleColor(UIColor.gray, for: .normal)
        self.hereEndLabel.textColor = UIColor.gray
         }
    
    func activateStart(){
        self.startButton.isEnabled = true
        self.startButton.setTitleColor(UIColor.white, for: .normal)
        self.hereStartLabel.textColor = UIColor.white
    }
    
    func activateEnd(){
        self.endButton.isEnabled = true
        self.endButton.setTitleColor(UIColor.white, for: .normal)
        self.hereEndLabel.textColor = UIColor.white
    }
}


// MARK: - Extensions
extension VideoProcessingViewController : VideoFramesManagerDelegate {
    func videoFramesAreReady(_ images: [UIImage]) {
        
        DispatchQueue.main.async {
            
            if !self.interrupt{
               print("before segue")
                self.beginImpotVideo = false
                    let videoProcessingViewController : AfterTrimViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AfterTrimViewController") as! AfterTrimViewController
                    videoProcessingViewController.tempVideo = self.videoAfterTrim
                    videoProcessingViewController.framesImages = images
                    self.navigationController?.pushViewController(videoProcessingViewController, animated: true)
                    UIUtils.instance.hideProgressHud()
            }
            else{
                self.interrupt = false
                self.beginImpotVideo = false
            }
        }
    }
    
    func videoImagesAreReady(_ images: [UIImage])
    {
        print("prepare Img")
        
    }
}


