//
//  Constants.swift
//  LoopVideo
//
//  Created by Minas Kamel on 9/8/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import Foundation

struct Constants {
    // AppURl
    static let LoopVideoAppId = "1148411673"
    static let FeedbackMailRecipient = "hend@nweave.com "
    static let FeedbackLoopVideoSubject = "Feedback Loop Video App"
    static let internetConnectionWarningShownForSearchRequest = "internetConnectionWarningShownForSearchRequest"
    
    //User Defalts
    static let IMAGES_COUNT = "imageCount"
    static let VIDEOS_COUNT = "VideosCount"
    static let IS_FIRST_TIME_OPENED = "isFirstTime"

    
    struct NSNotification {
        static let iapHelperProductPurchasedNotification = "iapHelperProductPurchasedNotification"
        static let iapHelperTransactionFailNotification = "iapHelperTransactionFailNotification"
        static let iapHelperUpdateTable = "iapHelperUpdateTable"
        static let hideAds = "hideAdsBannerView"
    }
    
    struct AdMob {
        static let bannerId = "ca-app-pub-7890890777708823/2865124392" //TODO: dummy, we used Karaoke's app id till we create one for Loop Video
        static let interstitialId = "ca-app-pub-7890890777708823/7016122397" //TODO: dummy, we used Karaoke's app id till we create one for Loop Video
    }
    
    struct IAP {
        static let productId = ""
    }
    
    struct Fblogin{
    static let userLoginFlag = "userLoginFlag"
    static let sessionID = "sessionUploadID"
        static let fbExpDate = "userLoginFbExpDate"
    }
    
    struct AppAlbum{
    static let albumName = "LOOP"
    }
    
    public enum FramesTypeScreen {
        case videoScreen
        case gifScreen
    }
    
}
