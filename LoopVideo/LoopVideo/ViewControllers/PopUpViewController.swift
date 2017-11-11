//
//  PopUpViewController.swift
//  LoopVideo
//
//  Created by hend elsisi on 10/30/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit
import FBSDKProfileExpressionKit

class PopUpViewController: UIViewController,fbUploadVideoDelegate {

    var AssetGridThumbnailSize = CGSize.zero
    var videoAsset: PHAsset!
     var videoData :NSData?
    var videoUrl:URL?
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        if Device.IS_3_5_INCHES_OR_SMALLER(){
       //  self.navigationController?.navigationBar.isHidden = true
        
        }
        self.getVideoData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getVideoData()
    {
        PHImageManager.default().requestAVAsset(forVideo: self.videoAsset, options: nil) {(avAsset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable: Any]?) -> Void in
            DispatchQueue.main.async(execute: {
                let url = ((avAsset as! AVURLAsset).url )
                self.videoUrl = url
                print(url.absoluteString)
                self.videoData = try? NSData(contentsOf: url)
            })
        }
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.parent!.dismissCurrentPopinController(animated: true)
    }
    
    @IBAction func fbProfile(_ sender: AnyObject) {
        
        if Reachability.checkRechability() {
          
            UIUtils.instance.showPorgressHudWithMessage("", view: self.view)
            if FBSDKProfileExpressionSharer.isProfileMediaUploadAvailable() {
                LoopVideoShareInterface.sharedLoopSharer().fbshare("", andShareType: ProfilePic, andDelegate: self, andVideoData: self.videoData as Data!, andIdentifier: self.videoAsset.localIdentifier)
                UIUtils.instance.hideProgressHud()
                 self.parent!.dismissCurrentPopinController(animated: true)
            }
            else{
                UIUtils.instance.hideProgressHud()
                var faceAppURL = URL(string: "https://itunes.apple.com/us/app/facebook/id284882215")!
                if UIApplication.shared.canOpenURL(faceAppURL) {
                    self.parent!.dismissCurrentPopinController(animated: true)
                    
                    UIApplication.shared.openURL(faceAppURL)
                }
                else{
                    
                    UIUtils.instance.showAlertView("Install FaceBook", message: "Please Install FaceBook App")
                     self.parent!.dismissCurrentPopinController(animated: true)
                }
            }
        }
        else{
            
            UIUtils.instance.showAlertWithMsg("Please ensure you are connected to the Internet", title: "No Internet conection")
        }
}
    
    @IBAction func fbWall(_ sender: AnyObject) {
      
        UIUtils.instance.showPorgressHudWithMessage("", view: self.view)
        LoopVideoShareInterface.sharedLoopSharer().instshare(toUrl: self.videoAsset.localIdentifier)
        UIUtils.instance.hideProgressHud()
         self.parent!.dismissCurrentPopinController(animated: true)
    }
    
    func loginAndShowCommentAlert()
    {
        if Reachability.checkRechability() {
            if self.userMustLogin()
            {
                var login = FBSDKLoginManager()
                let FACEBOOK_PERMISSIONS = ["public_profile", "email", "user_friends"]
                login.logIn(withReadPermissions: FACEBOOK_PERMISSIONS, from: self, handler: {(result, error) -> Void in
                    print("wferf \(result?.token.tokenString)")
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
                LoopVideoShareInterface.sharedLoopSharer().fbshare(caption, andShareType: WallPost, andDelegate: self, andVideoData: self.videoData as Data!, andIdentifier: self.videoAsset.localIdentifier)
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
    
    func userMustLogin() -> Bool
    {
        return UserDefaults.standard.bool(forKey: Constants.Fblogin.userLoginFlag) == false
            ||  UserDefaults.standard.bool(forKey: Constants.Fblogin.userLoginFlag) == true && Date().compare(UserDefaults.standard.object(forKey: Constants.Fblogin.fbExpDate) as! Date) != ComparisonResult.orderedAscending
    }
    
    
    @IBAction func fbmsn(_ sender: AnyObject) {
          UIUtils.instance.showPorgressHudWithMessage("", view: self.view)
        LoopVideoShareInterface.sharedLoopSharer().fbshare("", andShareType: Messenger, andDelegate: self, andVideoData: self.videoData as Data!, andIdentifier: self.videoAsset.localIdentifier)
        UIUtils.instance.hideProgressHud()
        self.parent!.dismissCurrentPopinController(animated: true)
    }
    
    
    func fbUploadVideoDelegateDidSuccess()
    {
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
    
}
    
extension PopUpViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuse", for: indexPath) as! ShareCollectionViewCell
        //  cell.backgroundColor = UIColor.yellowColor()
      //  cell.imageView.image = UIImage(named: "face")
        
//        PHImageManager.default().requestImage(for: self.videoAsset, targetSize: AssetGridThumbnailSize, contentMode: .aspectFill, options: nil) { (image:UIImage?, info:[AnyHashable : Any]?) in
//               cell.imageView.image = image
//        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
}

