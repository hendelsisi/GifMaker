//
//  VideoFramesViewController.swift
//  LoopVideo
//
//  Created by hend elsisi on 12/5/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit

class VideoFramesViewController: UIViewController {

    var imgFrames = [Any]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        print("clear")
        GifManager.shareInterface().cleanTempDir()
      
    }

}
extension VideoFramesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgFrames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FrameViewCell
         // cell.backgroundColor = UIColor.yellow
        var jpgName = self.imgFrames[indexPath.row]
        var img = GifManager.shareInterface().littleTempImage(withName: jpgName as! String)
        cell.imageView.image = img
        
        return cell
    }
}
