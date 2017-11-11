//
//  AdDisplayerManeger.swift
//  MusicPlayer
//
//  Created by yasmina elsisi on 3/6/16.
//  Copyright © 2016 nWeave LLC. All rights reserved.
//

import Foundation
class AdDisplayerManeger :InterstitialAdGenerator{
    
    static let instance  = AdDisplayerManeger()
    
    func displayInterstitialAd(_ adDisplayerController:UIViewController , delegate:InterstitialAdGeneratorDelegate)->Bool
    {
        self.delegate = delegate
        if canDisplayInterstitialAd(){
            self.createInterstitialAd(adDisplayerController)
            return true
        }
        return false
    }
    
    fileprivate func canDisplayInterstitialAd()->Bool
    {
        if !LoopVedioIAPHelper.instance.isUserPremium() && Reachability.checkRechability()  {
            return true
        }
        return false
    }
    
}
