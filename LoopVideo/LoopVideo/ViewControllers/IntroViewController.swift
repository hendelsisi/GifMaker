//
//  IntroViewController.swift
//  LoopVideo
//
//  Created by hend elsisi on 10/27/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {

    var people = [Any]()
    var layoutType : EBCardCollectionLayoutType?
    @IBOutlet weak var _collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var anOffset = UIOffset.zero
       
        anOffset = UIOffsetMake(40, 10)
        (self._collectionView.collectionViewLayout as! EBCardCollectionViewLayout).offset = anOffset
        (self._collectionView.collectionViewLayout as! EBCardCollectionViewLayout).layoutType = .horizontal
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

}

extension IntroViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! PersonCollectionViewCell
      if indexPath.item == 0
      {
        cell.personImageView.image = UIImage(named: "loboscator")
        
        }
        else if indexPath.item == 1
      {
        cell.personImageView.image = UIImage(named: "pepperpotts")
              }
        else if indexPath.item == 2
      {
        cell.personImageView.image = UIImage(named: "jcasarini")
       
        }
       
        
        return cell
    }
}
