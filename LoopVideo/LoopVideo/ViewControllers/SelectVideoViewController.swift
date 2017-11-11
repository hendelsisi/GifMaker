//
//  SelectVideoViewController.swift
//  LoopVideo
//
//  Created by Minas Kamel on 9/8/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit
import Photos

class SelectVideoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var beginImpotVideo:Bool = false
    var beginexportGif:Bool = false
    var interrupt:Bool = false
    var screenType:Constants.FramesTypeScreen?
    @IBOutlet weak var noVideosLabel: UILabel!
    var assetsFetchResults: PHFetchResult<PHAsset>?
    var selectedVideoAsset : PHAsset!
     var authorized:Bool = false
    var frames:[UIImage]?
    var count:Int = 0
    var videoAsset:AVAsset?
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func backToMainView(_ sender: UIBarButtonItem) {
        
      _ =  self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
            if self.authorized == true
            {
                self.fetchDeviceVideos()
            }
    }
    
    override func viewDidLoad() {
        self.title = "Select Video"
        behaveDependingOnVideoAccessAuthorization(PHPhotoLibrary.authorizationStatus())
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: UIApplication.shared)
         NotificationCenter.default.addObserver(self, selector: #selector(self.appdidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: UIApplication.shared)
    }
    
    func appdidEnterBackground(_ notification: Notification) {
        if (beginexportGif == true || beginImpotVideo == true)
        {self.interrupt = true}
    }
    
    func appWillEnterForeground(_ notification: Notification) {
        DispatchQueue.main.async{
            if self.authorized == true
            {
                self.fetchDeviceVideos()
            }
            if self.beginImpotVideo == true
            {
            UIUtils.instance.hideProgressHud()
                self.beginImpotVideo = false
            }
            
            if self.beginexportGif == true
            {
                UIUtils.instance.hideProgressHud()
                self.beginexportGif = false
            }
            
        }
    }
    
    //MARK: - Device vides access authorization
    func behaveDependingOnVideoAccessAuthorization(_ status : PHAuthorizationStatus) {
        switch status {
        case .notDetermined:
            requestAuthorizationToAccessVideos()
            break
        case .authorized:
             authorized = true
            fetchDeviceVideos()
            break
        case .denied, .restricted:
            showErrorMessage()
            break
        }
    }
    
    func requestAuthorizationToAccessVideos() {
        PHPhotoLibrary.requestAuthorization({ (status) in
            self.behaveDependingOnVideoAccessAuthorization(status)
        })
    }
    
    func showErrorMessage() {
        let alert = UIAlertController(title: "Warning", message: "Please authorize the app to access device photos from Settings > Privacy > Photos", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Fetch device videos
    func fetchDeviceVideos() {
        let duration = 2.0
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType == %d AND duration >= %f", PHAssetMediaType.video.rawValue, duration)
       /// options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        assetsFetchResults = PHAsset.fetchAssets(with: options)
        DispatchQueue.main.async {
            self.collectionView!.reloadData()
            if self.assetsFetchResults?.count == 0
            {
            self.noVideosLabel.isHidden = false
            }
            else{
            self.noVideosLabel.isHidden = true
            }
        }
    }
    
    // MARK: - Collection View Delegates
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.assetsFetchResults != nil{
            return self.assetsFetchResults!.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : VideoCell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.cellIdentifier, for: indexPath) as! VideoCell
        
        if self.assetsFetchResults != nil{
            let asset = self.assetsFetchResults![(indexPath as NSIndexPath).row]
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 138, height: 156), contentMode: .aspectFill, options: nil) { (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
                cell.videoThumbnailImage.image = image
            }
            let durationString = String(format:"%.2f", (asset.duration))
            cell.videoDuration.text = "\(durationString) secs"
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedVideoAsset = assetsFetchResults?[indexPath.row]
        
      //  AdDisplayerManeger.instance.displayInterstitialAd(self, delegate: self)
//        UIUtils.instance.showPorgressHudWithMessage("Loading...", view: self.view)
//        } else {
            prepareFramesToVideoProcessingScreen()
       // }
        }
    
    func prepareFramesToVideoProcessingScreen() {
            beginImpotVideo = true
                 DispatchQueue.main.async(execute: {
            UIUtils.instance.showPorgressHudWithMessage("Importing Video", view: self.view)
                    })
             VideoFramesManager.instance.delegate = self
             self.screenType = .videoScreen
             PHImageManager.default().requestAVAsset(forVideo: selectedVideoAsset, options: nil) {(avAsset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                self.videoAsset = avAsset
            VideoFramesManager.instance.extractVideoFrames(avAsset as! AVURLAsset)
            }
    }
    
    
    func prepareFramesGif(){
        
        PHImageManager.default().requestAVAsset(forVideo: selectedVideoAsset, options: nil) {(avAsset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
            VideoFramesManager.instance.delegate = self
            VideoFramesManager.instance.extractVideoFrames(avAsset as! AVURLAsset)
        }
      }
 }

// MARK: - Extensions
extension SelectVideoViewController : VideoFramesManagerDelegate {
    func videoFramesAreReady(_ images: [UIImage]) {
        
        DispatchQueue.main.async {
        
        if !self.interrupt{
            if self.screenType == .gifScreen
            {
                self.frames = images
                print("hjvgyv")
                _ = VideoFramesManager.instance.generateFramesPhotosFromSpecificTime(0.0)
            }
            else{
               
                self.beginImpotVideo = false
                let videoProcessingViewController : VideoProcessingViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "VideoProcessingViewController") as! VideoProcessingViewController
                videoProcessingViewController.tempVideo = self.videoAsset
                videoProcessingViewController.framesImages = images
                self.navigationController?.pushViewController(videoProcessingViewController, animated: true)
                 UIUtils.instance.hideProgressHud()
            }
        }
        else{
        self.interrupt = false
         self.beginImpotVideo = false
        }
        }
    }
    
    func videoImagesAreReady(_ images: [UIImage])
    {
       //navigation
        self.beginexportGif = false
        if !self.interrupt{
            
            DispatchQueue.main.async(execute: {
                UIUtils.instance.hideProgressHud()
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let imgDisplayerViewController: ImageDisplayerViewController = storyBoard.instantiateViewController(withIdentifier: "ImageDisplayer") as! ImageDisplayerViewController
                imgDisplayerViewController.images = images
                imgDisplayerViewController.startTime = 0.0
                imgDisplayerViewController.tasset = self.selectedVideoAsset
                imgDisplayerViewController.videoDuration = Double(self.selectedVideoAsset.duration)
                self.navigationController?.pushViewController(imgDisplayerViewController, animated: true)
            })
        
        }
        else{
        self.interrupt = false
        }
       
    }
}

extension SelectVideoViewController : InterstitialAdGeneratorDelegate {
    func interstitialAdWillDismissScreen() {
        DispatchQueue.main.async {
            //
        }
    }
    
    func interstitialAdDidRecived() {
        //  UIUtils.instance.hideProgressHud()
    }
}

