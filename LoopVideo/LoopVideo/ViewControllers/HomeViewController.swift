//
//  HomeViewController.swift
//  LoopVideo
//
//  Created by Minas Kamel on 9/8/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit
import AssetsLibrary
import MediaPlayer
import Photos
class HomeViewController: UIViewController {

    var savedVideosController: SavedVideosCollectionViewController!
    var selectVideosController: SelectVideoViewController!
    var cameraController: UIImagePickerController!
   // var screenType:Constants.FramesTypeScreen?
    var overlay:UIView!
     var movieLength:CMTime?
    var cameraVideo:AVAsset?
     var beginexportGif:Bool = false
     var beginImpotVideo:Bool = false
    var interrupt:Bool = false
     var retakeView:UIView!
    var isRecording:Bool = false
    var readyToStopRecord:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
         NotificationCenter.default.addObserver(self, selector: #selector(self.appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: UIApplication.shared)
         NotificationCenter.default.addObserver(self, selector: #selector(self.appdidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: UIApplication.shared)
    }
    
    @IBAction func myVideos(_ sender: AnyObject) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let imgDisplayerViewController: SelectVideoViewController = storyBoard.instantiateViewController(withIdentifier: "SelectVideoViewController") as! SelectVideoViewController
         self.navigationController?.pushViewController(imgDisplayerViewController, animated: true)
    }
    
    func appdidEnterBackground(_ notification: Notification) {
        self.interrupt = true
        UIUtils.instance.hideProgressHud()
    }
    
    func appWillEnterForeground(_ notification: Notification) {
        if self.isRecording == true
        {
        self.readyToStopRecord = false
        self.isRecording = false
        self.addRetake()
        self.overlay.isHidden = true
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    func startCameraFromViewController(viewController: UIViewController, withDelegate delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            return false
        }
        self.cameraController = UIImagePickerController()
        self.cameraController.sourceType = .camera
        self.cameraController.mediaTypes = [kUTTypeMovie as NSString as String]
        self.cameraController.allowsEditing = true
        self.cameraController.delegate = delegate
        if #available(iOS 10.0, *) {
            self.addoverlay()
            self.addRetake()
        }
        present(self.cameraController, animated: true, completion: nil)

        return true
    }
    
    
    @IBAction func startLoop(_ sender: AnyObject) {
       self.authorizedCam()
       //  startCameraFromViewController(viewController: self, withDelegate: self)
        
//        if #available(iOS 10.0, *) {
//        print("sfwerfrew")
//        }
    }
    
    func authorizedCam(){
        
        var authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if authStatus == .authorized {
            print("OK")
            self.startCameraFromViewController(viewController: self, withDelegate: self)
        }
        else if authStatus == .notDetermined {
            print("\("Camera access not determined. Ask for permission.")")
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {(_ granted: Bool) -> Void in
                if granted {
                    print("Granted access to \(AVMediaTypeVideo)")
                    self.startCameraFromViewController(viewController: self, withDelegate: self)
                }
                else {
                    print("Not granted access to \(AVMediaTypeVideo)")
                }
            })
        }
        else if authStatus == .restricted {
            
        }
        else {
            self.showErrorMessage()
        }
    }
    
    func showErrorMessage() {
        let alert = UIAlertController(title: "Warning", message: "Please authorize the app to access device photos from Settings > Moments > Camera", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addoverlay(){
        if Device.isPhone(){
         self.overlay = UIView(frame: CGRect(x: self.view!.frame.size.width / 2 - 35, y: self.view!.frame.size.height - 22, width: 70, height: 80))
        }
        else{
         self.overlay = UIView(frame: CGRect(x: self.view!.frame.size.width - 85, y: self.view!.frame.size.height / 2 - 8, width: 70, height: 70))
        }
       
    //    var test = UIView(frame: CGRect(x: self.view!.frame.size.width  - 75, y: self.view!.frame.size.height - 102, width: 70, height: 70))
        self.overlay.isUserInteractionEnabled = true
        self.overlay.backgroundColor = UIColor.clear
        var t = UITapGestureRecognizer(target: self, action: #selector(self.tapped ))
        self.overlay.addGestureRecognizer(t)
          self.cameraController.view.addSubview(self.overlay)
        }
    
    func addRetake(){
     self.retakeView = UIView(frame: CGRect(x: 10 , y: self.view!.frame.size.height + 6, width: 90, height: 50))
        self.retakeView.backgroundColor = UIColor.clear
        self.retakeView.isUserInteractionEnabled = true
        var tst = UITapGestureRecognizer(target: self, action: #selector(self.retake ))
        self.retakeView.isUserInteractionEnabled = true
        self.retakeView.addGestureRecognizer(tst)
        self.cameraController.view.addSubview(self.retakeView)
    }
    
    func addGesture(){
     var tap = UITapGestureRecognizer(target: self, action: #selector(self.retake ))
    self.cameraController.view.addGestureRecognizer(tap)
    }
    
    func retake( sender: UITapGestureRecognizer){
        self.cameraController.dismiss(animated: true, completion: nil)
         startCameraFromViewController(viewController: self, withDelegate: self)
    }
    
    func tapped(_ sender: Any) {
       
        if isRecording == false {
            self.isRecording = true
            self.cameraController.startVideoCapture()
            Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.targetMethod), userInfo: nil, repeats: false)
        }
        else if self.readyToStopRecord == true {
            self.cameraController.stopVideoCapture()
            self.readyToStopRecord = false
            self.isRecording = false
            self.addRetake()
            self.overlay.isHidden = true
        }
        
    }
    
    func targetMethod() {
        self.readyToStopRecord = true
    }
   
    func prepareFramesToVideoProcessingScreen() {
       
        beginImpotVideo = true
      //  DispatchQueue.main.async(execute: {
            UIUtils.instance.showPorgressHudWithMessage("Importing Video", view: self.view)
       // })
        VideoFramesManager.instance.delegate = self
      
        VideoFramesManager.instance.extractVideoFrames(self.cameraVideo as! AVURLAsset)
        }
    
    
  func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        UIUtils.instance.hideProgressHud()
    
            if let _ = error {
                var message = "Video failed to save"
                let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                }
             
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            let videoProcessingViewController : SelectVideoViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SelectVideoViewController") as! SelectVideoViewController
            self.navigationController?.pushViewController(videoProcessingViewController, animated: true)
    }
    
    }
    
    func prepareFramesGif(){
        
//        PHImageManager.default().requestAVAsset(forVideo: AlbumManager.getLastAsset(), options: nil) {(avAsset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
            VideoFramesManager.instance.delegate = self
            VideoFramesManager.instance.extractVideoFrames(self.cameraVideo as! AVURLAsset)
       // }
    }
    
    @IBAction func savedVideos(_ sender: UIButton) {
        
        let videoProcessingViewController : SavedVideosCollectionViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SavedVideosController") as! SavedVideosCollectionViewController
                    self.navigationController?.pushViewController(videoProcessingViewController, animated: true)
    }

}
extension HomeViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        if mediaType == kUTTypeMovie {
            guard let path = (info[UIImagePickerControllerMediaURL] as! NSURL).path else { return }
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
                
                var movie = AVAsset.init(url: (info[UIImagePickerControllerMediaURL] as! URL))
                self.movieLength = movie.duration
                 self.cameraVideo = movie
                self.prepareFramesToVideoProcessingScreen()
                
                
                }
        }
    }
    
}
extension HomeViewController: UINavigationControllerDelegate {
}

extension HomeViewController : VideoFramesManagerDelegate {
    
    func videoFramesAreReady(_ images: [UIImage]) {
        if !self.interrupt{
        
                self.beginImpotVideo = false
                 DispatchQueue.main.async(execute: {
                let videoProcessingViewController : VideoProcessingViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "VideoProcessingViewController") as! VideoProcessingViewController
                videoProcessingViewController.tempVideo = self.cameraVideo
                videoProcessingViewController.framesImages = images
                self.navigationController?.pushViewController(videoProcessingViewController, animated: true)
                UIUtils.instance.hideProgressHud()
                })
           // }
         
        }
        else{
         self.interrupt = false
             self.beginImpotVideo = false
        }
    }

    func videoImagesAreReady(_ images: [UIImage])
    {
        //navigation
        self.beginexportGif = false
        if !self.interrupt{
             DispatchQueue.main.async(execute: {
            let videoProcessingViewController : ImageDisplayerViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ImageDisplayer") as! ImageDisplayerViewController
            videoProcessingViewController.videoAssetBeforeSave = self.cameraVideo
            videoProcessingViewController.images = images
            self.navigationController?.pushViewController(videoProcessingViewController, animated: true)
            UIUtils.instance.hideProgressHud()
            })
        }
        else{
            self.interrupt = false
        }
    }
}
