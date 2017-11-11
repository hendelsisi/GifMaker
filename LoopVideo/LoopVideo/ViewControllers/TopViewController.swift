//
//  TopViewController.swift
//  LoopVideo
//
//  Created by Minas Kamel on 9/8/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase

class TopViewController: UIViewController, GADBannerViewDelegate {

    @IBOutlet var adBannerView: GADBannerView!
    @IBOutlet var adBannerViewHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        if !hideADBannerViewOnPremium() {
            createAdBannerView()
            NotificationCenter.default.addObserver(self, selector: #selector(TopViewController.productPurchased(_:)), name: NSNotification.Name(rawValue: Constants.NSNotification.iapHelperProductPurchasedNotification), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(TopViewController.hideAdBanner(_:)), name: NSNotification.Name(rawValue: Constants.NSNotification.hideAds), object: nil)
        }
    }

    func createAdBannerView()
    {
        adBannerView.adUnitID = Constants.AdMob.bannerId
        adBannerView.adSize = kGADAdSizeSmartBannerPortrait
        adBannerView.rootViewController = self
        adBannerView.delegate = self
        adBannerView.isAutoloadEnabled = true
        let request = GADRequest()
        request.testDevices = [kDFPSimulatorID];
        adBannerView.load(request)
        
    }
    //MARK: GADBannerViewDelegate functions
    func adViewDidReceiveAd(_ bannerView: GADBannerView!)
    {
        adBannerViewHeight.constant = 50
    }
    
    func adView(_ bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        adBannerViewHeight.constant = 0
    }
    
    // MARK: Product Purchased
    func productPurchased(_ notification : Notification)
    {
        hideADBannerViewOnPremium()
    }
    
    func hideADBannerViewOnPremium() -> Bool
    {
        if LoopVedioIAPHelper.instance.isUserPremium() {
            adBannerView.isHidden = true
            self.adBannerViewHeight.constant = 0
            adBannerView.delegate = nil
            return true
        }
        return false
    }
    
    func hideAdBanner(_ notification : Notification){
        adBannerView.isHidden = true
        self.adBannerViewHeight.constant = 0
        adBannerView.delegate = nil
    }

}
