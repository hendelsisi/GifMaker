//
//  InterstitialAdGenerator.swift
//

import Foundation
import UIKit
import GoogleMobileAds
import Firebase

protocol InterstitialAdGeneratorDelegate
{
    func interstitialAdWillDismissScreen()
    func interstitialAdDidRecived()
}

class InterstitialAdGenerator :NSObject, GADInterstitialDelegate {
    
    fileprivate var interstitial: GADInterstitial!
    
    var delegate : InterstitialAdGeneratorDelegate?
    fileprivate var adDisplayerController: UIViewController!
    var timeToDisableDismissButton : Double!
    var timer : Timer!
    
    func createInterstitialAd (_ adDisplayerController:UIViewController){
        timeToDisableDismissButton = 2.0
        self.adDisplayerController = adDisplayerController
        self.interstitial = GADInterstitial(adUnitID: Constants.AdMob.interstitialId)
        self.interstitial.delegate = self
        let request = GADRequest()
        
        // Requests test ads on test devices.
        request.testDevices = [kDFPSimulatorID]
        self.interstitial.load(request)
        
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial!) {
        
        
    }
    func interstitialWillDismissScreen(_ ad: GADInterstitial!) {
        Thread.sleep(forTimeInterval: abs(timeToDisableDismissButton))
        self.delegate?.interstitialAdWillDismissScreen()
    }
    
    func interstitial(_ ad: GADInterstitial!, didFailToReceiveAdWithError error: GADRequestError!) {
        createInterstitialAd(adDisplayerController)
    }
    
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial!) {
        ad.present(fromRootViewController: adDisplayerController)
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(InterstitialAdGenerator.decreaseTimer), userInfo: nil, repeats: true)
        self.delegate?.interstitialAdDidRecived()
    }
    
    func decreaseTimer(){
        if timeToDisableDismissButton <= 0{
            timer.invalidate()
            
        }else{
            timeToDisableDismissButton = timeToDisableDismissButton - 0.1
        }
        
    }
    
    
}
