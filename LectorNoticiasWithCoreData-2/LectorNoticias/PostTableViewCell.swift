//
//  PostTableViewCell.swift
//  LectorNoticias
//
//  Created by saqib on 29/08/2019.
//  Copyright © 2019 saqib. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
   
    
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var postFecha: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postExcerpt: UILabel!
    @IBOutlet weak var postAuthor: UILabel!
    @IBOutlet weak var postCategory: UILabel!
    
    
    
    override func prepareForReuse() {
       postImage.image = nil
       postTitle.text = nil
       postExcerpt.text = nil
       postAuthor.text = nil
       postFecha.text = nil
       postCategory.text = nil
    }

}
