//
//  Reachability.swift
//  MusicPlayer
//
//  Created by Minas Kamel on 8/17/15.
//  Copyright (c) 2015 nWeave LLC. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

class Reachability
{
    
    class func checkRechability() -> Bool
    {
        if !isConnectedToNetwork() {
            return false
        }
        UserDefaultsManager.instance.removeObject(Constants.internetConnectionWarningShownForSearchRequest)
        return true
    }
    
    class func checkRechabilityAndShowAlertView() -> Bool
    {
        if !checkRechability() {
            showNotConnectedWarningMessage()
            return false
        }
        return true
    }
    
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags(rawValue: 0)
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return isReachable && !needsConnection
    }
    
    class func showNotConnectedWarningMessage()
    {
        let messageIsShown : AnyObject? = UserDefaultsManager.instance.getObjectForKey(Constants.internetConnectionWarningShownForSearchRequest)
        if messageIsShown == nil || !(messageIsShown as! Bool) {
            DispatchQueue.main.async {
                let alert = UIAlertView(title: "No Internet conection", message: "Please ensure you are connected to the Internet", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            UserDefaultsManager.instance.saveObject(true as AnyObject, key: Constants.internetConnectionWarningShownForSearchRequest)
        }
    }

}
