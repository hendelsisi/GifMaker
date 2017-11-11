//
//  UIUtils.swift
//  LoopVideo
//
//  Created by Minas Kamel on 9/19/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import Foundation

class UIUtils {

    static let instance = UIUtils()
    var progressHud : MBProgressHUD?
    
    //MARK: - MBProgressHud
    func showPorgressHudWithMessage(_ message : String, view : UIView) {
        DispatchQueue.main.async {
            self.progressHud = MBProgressHUD.showAdded(to: view, animated: true)
            self.progressHud?.labelText = message;
        }
    }
    
    func hideProgressHud() {
        DispatchQueue.main.async {
            if self.progressHud != nil && !self.progressHud!.isHidden {
                self.progressHud!.hide(true)
            }
        }
        
    }
    
    func showAlertWithMsg(_ msg:String,title:String){
        let alert = UIAlertView(title: title, message: msg, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func showAlertView(_ title: String, message: String){
        let alertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
    }
}
