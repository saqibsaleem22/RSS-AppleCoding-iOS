//
//  FavCollectionViewCell.swift
//  LectorNoticias
//
//  Created by saqib on 29/08/2019.
//  Copyright © 2019 saqib. All rights reserved.
//

import UIKit

class FavCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var favImage: UIImageView!
    @IBOutlet weak var favTitle: UILabel!
    @IBOutlet weak var favAutor: UILabel!
    
    
    
   
    
    override func prepareForReuse() {
        favImage.image = nil
        favTitle.text = nil
        favAutor.text = nil
    }
}
