//
//  CustomAlbumCreator.swift
//  LoopVideo
//
//  Created by yasmina elsisi on 9/28/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit
import Photos

protocol SaveImagesDeleget {
    func imagesSavedSuccess()
    func imagesNotSaved()
}

class CustomAlbumCreator: NSObject {
    static let sharedInstance = CustomAlbumCreator()
    var delegate : SaveImagesDeleget?
    let group = DispatchGroup()
    var assetCollection: PHAssetCollection!
    let albumName = "LOOP"
    
    func getAlbum(){
        
        //DispatchQueue.global(qos: .background).async {
        self.group.enter()
        
        var albumFound : Bool = false
        let options:PHFetchOptions = PHFetchOptions()
        
        options.predicate = NSPredicate(format: "estimatedAssetCount >= 0")
            
        let userAlbums:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: options)
        
        userAlbums.enumerateObjects({ (object: AnyObject!, count: Int, stop: UnsafeMutablePointer) in
            if object is PHAssetCollection {
                let obj:PHAssetCollection = object as! PHAssetCollection
                if obj.localizedTitle == self.albumName  {
                    self.assetCollection = obj
                    albumFound = true
                    self.group.leave()
                    stop.initialize(to: true)
                }
            }
        })
            
        if !albumFound{
            var assetCollectionPlaceholder:PHObjectPlaceholder!
                
            PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)
                assetCollectionPlaceholder = request.placeholderForCreatedAssetCollection
            }, completionHandler: { (success, error) in
                if (success) {
                    let result:PHFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [assetCollectionPlaceholder.localIdentifier], options: nil)
                self.assetCollection = result.firstObject! as PHAssetCollection
                albumFound = true
                self.group.leave()
                }
            })
        }
        //}
    }

    func saveImage(image: UIImage) {
        
        self.getAlbum()
        group.notify(queue: DispatchQueue.main) {
        //DispatchQueue.global(qos: .background).async {
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            albumChangeRequest!.addAssets([assetPlaceHolder!] as NSArray)
            
            }, completionHandler: { (success, error) in
                if (success) {
                    DispatchQueue.main.async {
                        self.delegate?.imagesSavedSuccess()
                    UIUtils.instance.showAlertView("Image Saved Sucessfully", message: "")
                    }
                }else{
                    self.delegate?.imagesNotSaved()
                    print("Error: \(error)")
                }
        })
        //}
        }
    }
    
      func saveVideo(filePath:NSURL) {
        self.getAlbum()
        group.notify(queue: DispatchQueue.main) {
            //DispatchQueue.global(qos: .background).async {
                
                PHPhotoLibrary.shared().performChanges({
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: filePath as URL)
                    let assetPlaceHolder = assetChangeRequest?.placeholderForCreatedAsset
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                    albumChangeRequest!.addAssets([assetPlaceHolder!] as NSArray)
                    }, completionHandler: { (success, error) in
                        if (success) {
                            DispatchQueue.main.async {
                                self.delegate?.imagesSavedSuccess()
                                UIUtils.instance.showAlertView("Video Saved Sucessfully", message: "")
                            }
                        }else{
                            self.delegate?.imagesNotSaved()
                            print("Error: \(error)")
                        }
                    })
            }
        //}
    }
    
    func deleteVideos(fastEnumeration: [PHAsset])
    {
        //DispatchQueue.global(qos: .background).async {
        self.group.enter()
        PHPhotoLibrary.shared().performChanges({
//        if let request = PHAssetCollectionChangeRequest(for: self.assetCollection){
//            request.removeAssets(fastEnumeration as NSFastEnumeration) }
            PHAssetChangeRequest.deleteAssets(fastEnumeration as NSFastEnumeration)
            
            }, completionHandler: {(success, error)in
                if(!success){
                    print("Error: \(error)")
                    self.group.leave()
                }
                else{
                    self.group.leave()
                }
            })
        //}
    }
}
