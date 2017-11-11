//
//  VideosCollectionViewController.swift
//  LoopVideo
//
//  Created by Shimaa Saeed on 10/13/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit
import Photos
import AVKit
import AVFoundation

class SavedVideosCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var authorized:Bool = false
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    @IBOutlet weak var noVideosLabel: UILabel!
    var albumFound : Bool = false
    var assetCollection: PHAssetCollection = PHAssetCollection()
    var photosAsset: PHFetchResult<PHAsset>!
    var assetThumbnailSize:CGSize!
    var selectedCells = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        behaveDependingOnVideoAccessAuthorization(PHPhotoLibrary.authorizationStatus())
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: UIApplication.shared)
    }
    
    func appWillEnterForeground(_ notification: Notification) {
        DispatchQueue.main.async{
            if self.authorized == true
            {
                self.fetchAlbumVideos()
            }
        }
    }
    
    
    @IBAction func playVideo(_ sender: AnyObject) {
        
        var buttonPosition = sender.convert(CGPoint.zero, to: self.collectionView)
        var indexPath = self.collectionView.indexPathForItem(at: buttonPosition)
        var itemNo = indexPath?.item
        var asset = self.photosAsset[itemNo!]
        
        //  var videoPlayer:AVPlayer? = nil
        PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { ( avAsset:AVAsset?, mx:AVAudioMix?, info:[AnyHashable : Any]?) in
            
            var avAsset = AVURLAsset.init(url: (avAsset as! AVURLAsset).url, options: nil)
            var playerItem = AVPlayerItem.init(asset: avAsset)
            var  videoPlayer = AVPlayer.init(playerItem: playerItem)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = videoPlayer
            DispatchQueue.main.async(execute: {
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()}
            })
        }
    }
    
    @IBAction func share(_ sender: AnyObject) {
       
        if Reachability.checkRechability() {
            var buttonPosition = sender.convert(CGPoint.zero, to: self.collectionView)
            var indexPath = self.collectionView.indexPathForItem(at: buttonPosition)
            var itemNo = indexPath?.item
            var asset = self.photosAsset[itemNo!]
            //////////////////////////////////
            var popin = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PopViewController") as! PopUpViewController)
            popin.videoAsset = asset
            if Device.isPhone(){
            popin.view.bounds = CGRect(x: 0, y: 0, width: 366, height: 510)
            }
            else{
            popin.view.bounds = CGRect(x: 0, y: 0, width: 500, height: 900)
            }
            
            //        if Device.isPhone() && Device.IS_4_7_INCHES_OR_LARGER()
            //        {
            //         popin.view.bounds = CGRect(x: 0, y: 0, width: 366, height: 530)
            //
            //        }
            
            self.presentPopinController(popin, animated: true, completion: {() -> Void in
                print("Popin presented !")
            })
        }
        else{
         UIUtils.instance.showAlertWithMsg("Please ensure you are connected to the Internet", title: "No Internet conection")
        
        }
    }
    func behaveDependingOnVideoAccessAuthorization(_ status : PHAuthorizationStatus) {
        switch status {
        case .notDetermined:
            requestAuthorizationToAccessVideos()
            break
        case .authorized:
            authorized = true
            fetchAlbumVideos()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if self.photosAsset != nil {
            return self.photosAsset.count
        }
        return 0;
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func selectVideo(_ sender:UIButton) {
        let index = sender.layer.value(forKey: "index") as! Int
        
        if selectedCells.contains(index){
            selectedCells.remove(index)
            
            //sender.isHidden = true
            sender.setBackgroundImage(UIImage(named:"Diselect.png"), for: UIControlState.normal)
        }
        else{
            selectedCells.add(index)
            //sender.isHidden = false
            sender.setBackgroundImage(UIImage(named:"Select.png"), for: UIControlState.normal)
        }
        
        //print("delete at: \(i)")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SavedVideoCell
        
        if self.photosAsset != nil{
            self.assetThumbnailSize = cell.bounds.size
            let asset: PHAsset = self.photosAsset![indexPath.item]
            
            PHImageManager.default().requestImage(for: asset, targetSize: self.assetThumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: {(result, info)in
                if let image = result {
                    DispatchQueue.main.async{
                        cell.video.image = image
                    }
                }
            })
            
            cell.selectButton?.layer.setValue((indexPath as NSIndexPath).row, forKey: "index")
            cell.selectButton?.addTarget(self, action: #selector(SavedVideosCollectionViewController.selectVideo(_:)), for: UIControlEvents.touchUpInside)
            
            if selectedCells.contains(indexPath.row){
                cell.selectButton.setBackgroundImage(UIImage(named:"Select.png"), for: UIControlState.normal)
            }
            else{
                cell.selectButton.setBackgroundImage(UIImage(named:"Diselect.png"), for: UIControlState.normal)
            }
        }
        
        return cell
    }
    
    func fetchAlbumVideos() {
        UIUtils.instance.showPorgressHudWithMessage("", view: self.view)
        if( !AlbumManager.albumxist())
        {
            DispatchQueue.main.async{
                self.noVideosLabel.isHidden = false
                self.photosAsset = nil
                
                self.collectionView!.reloadData()
                UIUtils.instance.hideProgressHud()
            }
           
        }
        else{
            
            CustomAlbumCreator.sharedInstance.getAlbum()
            CustomAlbumCreator.sharedInstance.group.notify(queue: DispatchQueue.main) {
                self.assetCollection = CustomAlbumCreator.sharedInstance.assetCollection
                self.photosAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
                DispatchQueue.main.async{
                    if self.photosAsset == nil || self.photosAsset.count == 0{
                        self.noVideosLabel.isHidden = false
                        UIUtils.instance.hideProgressHud()
                    }
                    else{
                        self.noVideosLabel.isHidden = true
                        UIUtils.instance.hideProgressHud()
                    }
                    self.collectionView!.reloadData()
                    UIUtils.instance.hideProgressHud()
                }
            }
        }}
    
    
    
    @IBAction func backToMainView(_ sender: UIBarButtonItem) {
        
         _ =  self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deletVideos(_ sender: UIBarButtonItem) {
        if(self.collectionView.numberOfItems(inSection: 0) == 0){
            UIUtils.instance.showAlertView("", message: "No Videos To delete")
        }
            
        else if(self.selectedCells.count == 0){
            UIUtils.instance.showAlertView("", message: "Please Select Video to delete")
        }
        else{
            
            let alert = UIAlertController(title: "Delete Video", message: "Are you sure you want to delete selected video/s?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(alertAction)in
                
                var fastEnumeration = [PHAsset]()
                
                for i in 0..<self.selectedCells.count{
                    let index = self.selectedCells[i] as! Int
                    fastEnumeration.append(self.photosAsset[index])
                }
                self.selectedCells.removeAllObjects()
                print("count:\(self.selectedCells.count)")
                
                CustomAlbumCreator.sharedInstance.deleteVideos(fastEnumeration: fastEnumeration)
                CustomAlbumCreator.sharedInstance.group.notify(queue: DispatchQueue.main) {
                    
                    self.assetCollection = CustomAlbumCreator.sharedInstance.assetCollection
                    self.photosAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
                    
                    DispatchQueue.main.async{
                        alert.dismiss(animated: true, completion: nil)
                        self.collectionView!.reloadData()
                        if self.photosAsset.count == 0 {
                            self.noVideosLabel.isHidden = false
                        }
                    }
                }
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(alertAction)in
                self.selectedCells.removeAllObjects()
                DispatchQueue.main.async{
                    alert.dismiss(animated: true, completion: nil)
                    self.collectionView!.reloadData()
                }
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}
