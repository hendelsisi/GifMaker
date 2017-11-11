//
//  RootViewController.swift
//  LoopVideo
//
//  Created by hend elsisi on 10/27/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    @IBOutlet weak var cameraAccessLabel: UILabel!
    @IBAction func switchCam(_ sender: Any) {
       
    //Add effect
        
        flashButton.isHidden = !flashButton.isHidden
        
    }
    
    @IBAction func flash(_ sender: Any) {
        
    }
    
    @IBOutlet weak var flashButton: UIButton!
    
    @IBOutlet weak var previewView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //
        UserDefaults.standard.set(true, forKey: "getR")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        var authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if authStatus == .authorized {
            self.cameraAccessLabel.isHidden = true
        }
        else{
        self.cameraAccessLabel.isHidden = false
        }
    }
}

extension RootViewController:AVCaptureVideoDataOutputSampleBufferDelegate{


}
