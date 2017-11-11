//
//  SavedVideosViewController.swift
//  LoopVideo
//
//  Created by Minas Kamel on 9/8/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit
import PhotosUI
import Photos
import FBSDKProfileExpressionKit

class SavedVideosViewController: UIViewController ,UINavigationControllerDelegate,UINavigationBarDelegate,fbUploadVideoDelegate{
    var assetsFetchResults: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    var sectionFetchResults = [AnyObject]()
    var videoData :NSData?
    var videoUrl:URL?
    var tasset: PHAsset!
    var AssetGridThumbnailSize = CGSize.zero
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func shareInst(_ sender: AnyObject) {
        LoopVideoShareInterface.sharedLoopSharer().instshare(toUrl: self.tasset.localIdentifier)
    }
    
    
    func userMustLogin() -> Bool{
        return UserDefaults.standard.bool(forKey: Constants.Fblogin.userLoginFlag) == false
    }

    func loginAndShowCommentAlert(){
        if Reachability.checkRechability() {
            if self.userMustLogin()
            {
                var login = FBSDKLoginManager()
                let FACEBOOK_PERMISSIONS = ["public_profile", "email", "user_friends"]
                login.logIn(withReadPermissions: FACEBOOK_PERMISSIONS, from: self, handler: {(result, error) -> Void in
                    print("wferf \(result?.token.tokenString)")
                    UserDefaults.standard.set(true, forKey: Constants.Fblogin.userLoginFlag)
                    self.theAlert()
                })
            }
            else{
              
                self.theAlert()
            }
        }
        else{
            UIUtils.instance.showAlertWithMsg("Please ensure you are connected to the Internet", title: "No Internet conection")
        }
    }
    
    func shareVideo(_ caption:String) {
        DispatchQueue.main.async(execute: {
            
            var params:NSMutableDictionary? = [
                "video.mov" : self.videoData!,
                "contentType" : "video/quicktime",
                "title" : " LooP Video",
                "description" : caption
            ]
            
            if Reachability.checkRechability() {
                UserDefaults.standard.set(true, forKey: "uploading")
                UIUtils.instance.showPorgressHudWithMessage("Uploading Video", view: self.view)
                LoopVideoShareInterface.sharedLoopSharer().fbshare(caption, andShareType: WallPost, andDelegate: self, andVideoData: self.videoData as Data!, andIdentifier: self.tasset.localIdentifier)
            }
            else{
                
                UIUtils.instance.showAlertWithMsg("Please ensure you are connected to the Internet", title: "No Internet conection")
            }
            
        })
    }
    
    func theAlert(){
        
        let alertController = UIAlertController(title: "", message: "Please Enter a Caption", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Post", style: UIAlertActionStyle.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            print("text \(alertController.textFields?[0].text)")
            self.shareVideo((alertController.textFields?[0].text)!)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.addTextField { ( textfield:UITextField) in
            textfield.placeholder = "Hi people watch My Loop Video"
        }
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func showActionSheet(){
        print("jkhuh")
        let optionMenu = UIAlertController(title: nil, message: "Select Option", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Share on Facebook", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Face")
           // self.theAlert()
            self.loginAndShowCommentAlert()
        })
        let saveAction = UIAlertAction(title: "Send with Messenger", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("msn")
            LoopVideoShareInterface.sharedLoopSharer().fbshare("", andShareType: Messenger, andDelegate: self, andVideoData: self.videoData as Data!, andIdentifier: self.tasset.localIdentifier)
        })
        let action = UIAlertAction(title: "Use as Profile Video", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("FacePic")
            LoopVideoShareInterface.sharedLoopSharer().fbshare("", andShareType: ProfilePic, andDelegate: self, andVideoData: self.videoData as Data!, andIdentifier: self.tasset.localIdentifier)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(action)
        optionMenu.addAction(cancelAction)
        if let wPPC = optionMenu.popoverPresentationController {
            wPPC.sourceView = self.view
        }
        self.present(optionMenu, animated: true, completion: nil)
    }

    @IBAction func sdfe(_ sender: AnyObject) {
        print("shareFbPressed")
        showActionSheet()
    }
    func fbUploadVideoDelegateDidFailed(){
        UIUtils.instance.hideProgressHud()
                UserDefaults.standard.set(false, forKey: "uploading")
                if Reachability.checkRechability()
                {
                    UIUtils.instance.showAlertWithMsg("Failed to share Video", title: "")
                }
                else{
                    UIUtils.instance.showAlertWithMsg("Please ensure you are connected to the Internet", title: "No Internet conection")
                }
    }
    
    func fbUploadVideoDelegateDidSuccess(){
        UIUtils.instance.hideProgressHud()
                UserDefaults.standard.set(false, forKey: "uploading")
                UIUtils.instance.showAlertWithMsg("Video is Shared Successfully", title: "")
    }
    
    @IBAction func morePressed(sender: AnyObject) {
       
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docDirectory = paths[0]
        let filePath = "\(docDirectory)/tmpVideo.mov"
        self.videoData?.write(toFile: filePath, atomically: true)
        
        let videoLink = NSURL(fileURLWithPath: filePath)
        let objectsToShare = [videoLink]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.setValue("Video", forKey: "subject")
        DispatchQueue.main.async(execute: { () -> Void in
            if let wPPC = activityVC.popoverPresentationController {
                wPPC.sourceView = self.view
            }
            print("This is run on the main queue, after the previous code in outer block")
         
            self.present(activityVC, animated: true, completion: nil)
        })
        
    }
    
    @IBAction func savePressed(sender: AnyObject) {
    }
    
    func getVideoData(){
        
        PHImageManager.default().requestAVAsset(forVideo: self.tasset, options: nil) {(avAsset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable: Any]?) -> Void in
            DispatchQueue.main.async(execute: {
                let url = ((avAsset as! AVURLAsset).url )
                self.videoUrl = url
                print(url.absoluteString)
                self.videoData = try? NSData(contentsOf: url)
                
            })
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("guygu")
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        // Add button to the navigation bar if the asset collection supports adding content.
        if UserDefaults.standard.bool(forKey: "uploading")
        {  UIUtils.instance.showPorgressHudWithMessage("Uploading Video", view: self.view)}
    }
    
      override func viewDidLoad() {
        super.viewDidLoad()
            
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        assetsFetchResults = PHAsset.fetchAssets(with: options)
        self.tasset = self.assetsFetchResults[0] as PHAsset
        PHImageManager.default().requestImage(for: ((assetsFetchResults?[0])! as PHAsset), targetSize: AssetGridThumbnailSize, contentMode: .aspectFill, options: nil) { (image: UIImage?, info: [AnyHashable : Any]?) -> Void in
        self.assetsFetchResults = PHAsset.fetchAssets(with: options)
        self.tasset = self.assetsFetchResults[0]
        var assetsFetchResultsAsPHAsset : PHAsset? = PHAsset()
        assetsFetchResultsAsPHAsset = self.assetsFetchResults?[0]
        PHImageManager.default().requestImage(for: assetsFetchResultsAsPHAsset!, targetSize: self.AssetGridThumbnailSize, contentMode: .aspectFill, options: nil) { (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
            self.imageView.image = image
        }
          self.getVideoData()
    }
    
    func shareFbPressed(_ sender: AnyObject) {
        print("shareFbPressed")
        showActionSheet()
        
    }
  
}

}


