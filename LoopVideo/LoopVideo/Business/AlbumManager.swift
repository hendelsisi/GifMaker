//
//  AlbumManager.swift
//  LoopVideo
//
//  Created by hend elsisi on 10/25/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit

class AlbumManager: NSObject {
  static var assetCollection:PHAssetCollection?
   
    public class  func albumxist( ) -> Bool {
    var val:Bool?
    
    let concurrentQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
    concurrentQueue.sync {
        
        var options = PHFetchOptions()
        options.predicate = NSPredicate(format: "title = %@", Constants.AppAlbum.albumName)
        var fetch = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
         val = fetch.firstObject != nil
//       
    }
        return val!
    }
    
  public class  func  createAlbum(fpath:String)
    {
        print("uihoui")
        PHPhotoLibrary.shared().performChanges({
            var createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: Constants.AppAlbum.albumName)
            var assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }, completionHandler: { success, error in
                print("created")
                self.saveNewVideo(toCameraRoll: NSURL.fileURL(withPath: fpath))
        })
    }
    
  public class  func setAssetCollection() {
        var options = PHFetchOptions()
        options.predicate = NSPredicate(format: "title = %@", Constants.AppAlbum.albumName)
        var fetch = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        self.assetCollection = fetch.firstObject
    }
    
  public class  func saveNewVideo(toCameraRoll vUrl: URL) {
        self.setAssetCollection()
        PHPhotoLibrary.shared().performChanges({() -> Void in
            print("Test vurl \(vUrl)")
            var assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: vUrl)
            var assetplace = assetChangeRequest?.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest.init(for: self.assetCollection!)
            albumChangeRequest?.addAssets([assetplace!] as NSArray)
            //
            }, completionHandler: {(success: Bool, error: Error?) -> Void in
                //
                if success {
                    print("saved")
                     DispatchQueue.main.async{
                    UIUtils.instance.hideProgressHud()
                    UIUtils.instance.showAlertView("Video Saved Successfully", message: "")
                    }
                }
        })
    }
    
   class func getLastAsset()-> PHAsset{
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
     let systemVersion = UIDevice.current.systemVersion
    var  assetsFetchResults = PHAsset.fetchAssets(with: options)
    print("number \(assetsFetchResults.count)")
    
//    if  (systemVersion as NSString).doubleValue > 8.0{
//     return assetsFetchResults.lastObject!
//    }
//    else{
    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        assetsFetchResults = PHAsset.fetchAssets(with: options)
        return assetsFetchResults.firstObject!
   // }
    }
    
}
