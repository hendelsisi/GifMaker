//
//  ImageDisplayerViewController.swift
//  LoopVideo
//
//  Created by yasmina elsisi on 9/26/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit
import AssetsLibrary
import MediaPlayer
import Photos
import Social

class ImageDisplayerViewController: UIViewController,UINavigationControllerDelegate,UINavigationBarDelegate,fbUploadVideoDelegate,SaveImagesDeleget {
    
    var videoData :NSData?
    var videoUrl:URL?
    var tasset : PHAsset!
    var isSaved:Bool?
    var videoAssetBeforeSave:AVAsset?
    var saveVideoFirst:Bool = false
    var startTime:CGFloat?
    var videoDuration:Double?
    
    @IBOutlet weak var selectedImg: UIImageView!
    var images = [UIImage]()
    var imagNumber = 0
    
    @IBAction func saveVideo(_ sender: AnyObject) {
        self.saveAsVideo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.animateImages()
        self.getVideoData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: ActionSheets
    func showSaveActionSheet()
    {
        let optionMenu = UIAlertController(title: nil, message: "Select Option", preferredStyle: .actionSheet)
        
        let saveAsGIFAction = UIAlertAction(title: "Save as GIF image", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.saveAsGIF()
        })
        let saveAsVideoAction = UIAlertAction(title: "Save as Video", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            UIUtils.instance.showPorgressHudWithMessage("Saving...", view: self.view)
            self.saveAsVideo()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
        }
        optionMenu.addAction(saveAsGIFAction)
        optionMenu.addAction(saveAsVideoAction)
         optionMenu.addAction(cancelAction)
        if let wPPC = optionMenu.popoverPresentationController {
            wPPC.sourceView = self.view
        }
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    func showFacebookActionSheet(){
        let optionMenu = UIAlertController(title: nil, message: "Select Option", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Share on Facebook", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Face")
            // self.theAlert()
            self.loginAndShowCommentAlert()
        })
        let saveAction = UIAlertAction(title: "Send with Messenger", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("msg")
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
    

    // MARK: Outlet Actions
    @IBAction func fbShare(sender: AnyObject)
    {
        print("shareFbPressed")
        showFacebookActionSheet()
    }
    
    @IBAction func instShare(sender: AnyObject)
    {
        LoopVideoShareInterface.sharedLoopSharer().instshare(toUrl: self.tasset.localIdentifier)
    }
   
    @IBAction func sharePressed(sender: AnyObject)
    {
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
    
    @IBAction func saveVideo(sender: AnyObject)
    {
        showSaveActionSheet()
    }
    
    // MARK: fbUploadVideoDelegate
    func fbUploadVideoDelegateDidSuccess()
    {
        print("success")
        UIUtils.instance.hideProgressHud()
        UserDefaults.standard.set(false, forKey: "uploading")
        UIUtils.instance.showAlertWithMsg("Video is Shared Successfully", title: "")
    }
    
    func fbUploadVideoDelegateDidFailed()
    {
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
    
    //MARK: SaveImagesDeleget
    func imagesSavedSuccess()
    {
        UIUtils.instance.hideProgressHud()
    }
    func imagesNotSaved()
    {
        UIUtils.instance.showAlertView("Error", message:"Please Try again")
        UIUtils.instance.hideProgressHud()
        
    }
    
    // MARK: Helper Functions
    private func saveAsVideo()
    {
       UIUtils.instance.showPorgressHudWithMessage("Saving", view: self.view)
        
        var trime = TrimeVideo()
        print("start At : \(self.startTime)")
        trime.startTime = self.startTime!
        if (self.videoDuration! < 10.0 ){
         trime.stopTime = self.startTime! + 2
        }
        else{
        trime.stopTime = self.startTime! + 10
        }
        trime.asset = self.tasset
        
        trime.trimeVideo({ (success, fpath) in
            UIUtils.instance.hideProgressHud()
            if success{
                if !AlbumManager.albumxist()
                {
                    AlbumManager.createAlbum(fpath: fpath!)
                }
                else{
                    AlbumManager.saveNewVideo(toCameraRoll: NSURL.fileURL(withPath: fpath!))
                }
            }
            else{
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
    
    private func saveAsGIF()
    {
        UIUtils.instance.showPorgressHudWithMessage("Saving...", view: self.view)
        let gifImg = UIImage(contentsOfFile: GIFGenerator.instance.createGIFImg(images))
        CustomAlbumCreator.sharedInstance.delegate = self
        LoopControllerManager.instance.save(object: gifImg!)
    }
    
    fileprivate func animateImages()
    {
        self.selectedImg.image = images[imagNumber]
        imagNumber += 1
        self.selectedImg.animationImages = images
        self.selectedImg.animationDuration = 2
        self.selectedImg.startAnimating()
    }
    
    func userMustLogin() -> Bool
    {
        return UserDefaults.standard.bool(forKey: Constants.Fblogin.userLoginFlag) == false
            ||  UserDefaults.standard.bool(forKey: Constants.Fblogin.userLoginFlag) == true && Date().compare(UserDefaults.standard.object(forKey: Constants.Fblogin.fbExpDate) as! Date) != ComparisonResult.orderedAscending
    }
    
    func shareVideo(_ caption:String)
    {
        DispatchQueue.main.async(execute: {
            
            let params:NSMutableDictionary? = [
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
    
    
    func loginAndShowCommentAlert()
    {
        if Reachability.checkRechability() {
            if self.userMustLogin()
            {
                var login = FBSDKLoginManager()
                let FACEBOOK_PERMISSIONS = ["public_profile", "email", "user_friends"]
                login.logIn(withReadPermissions: FACEBOOK_PERMISSIONS, from: self, handler: {(result, error) -> Void in
                   // print("wferf \(result?.token.tokenString)")
                    UserDefaults.standard.set(true, forKey: Constants.Fblogin.userLoginFlag)
                    UserDefaults.standard.set (result?.token.expirationDate,forKey: Constants.Fblogin.fbExpDate)
                    
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
    
    func getVideoData()
    {
        if self.videoAssetBeforeSave != nil{
            let url = ((self.videoAssetBeforeSave as! AVURLAsset).url )
            self.videoUrl = url
            print(url.absoluteString)
            self.videoData = try? NSData(contentsOf: url)
        }
        else{
            PHImageManager.default().requestAVAsset(forVideo: self.tasset, options: nil) {(avAsset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable: Any]?) -> Void in
                DispatchQueue.main.async(execute: {
                    let url = ((avAsset as! AVURLAsset).url )
                    self.videoUrl = url
                    print(url.absoluteString)
                    self.videoData = try? NSData(contentsOf: url)
                })
            }
        }
    }
    
}
