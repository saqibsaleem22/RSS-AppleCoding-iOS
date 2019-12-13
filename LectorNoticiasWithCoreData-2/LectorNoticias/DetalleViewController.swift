//
//  DetalleViewController.swift
//  LectorNoticias
//
//  Created by saqib on 31/08/2019.
//  Copyright © 2019 saqib. All rights reserved.
//

import UIKit
import WebKit
import CoreData

class DetalleViewController: UIViewController {

    @IBOutlet weak var titleDetalle: UILabel!
    @IBOutlet weak var detallWebView: DetalleWebKit!
    @IBOutlet weak var favButton: UIBarButtonItem!
    
    var detallePost:NoticiaDB?
    
    override func viewDidLoad() {
        if let post = detallePost {
            let content = post.contentNoticia!
            let sizer = "<meta name=\"viewport\" content=\"initial-scale=1\" />"
            detallWebView.loadHTMLString(sizer + content, baseURL: nil)
            titleDetalle.text = post.titleNoticia
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let post = detallePost {
            favButton.title = post.fav ? "Quitar de favoritos" : "Añadir a favoritos"
        } 
    }
    
    @IBAction func addFav(_ sender: UIBarButtonItem) {
        guard let post = detallePost else {
            return
        }
            if favButton.title == "Quitar de favoritos" {
                favButton.title = "Añadir a favoritos"
                post.fav.toggle()
                saveContext()
                print("Removed from favorites")
            } else {
                favButton.title = "Quitar de favoritos"
                post.fav.toggle()
                print("Added to favorites")
                saveContext()
            }
        
        }
    
    
   
}
