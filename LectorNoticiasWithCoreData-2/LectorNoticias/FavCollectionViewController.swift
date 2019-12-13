//
//  FavCollectionViewController.swift
//  LectorNoticias
//
//  Created by saqib on 29/08/2019.
//  Copyright © 2019 saqib. All rights reserved.
//

import UIKit
import CoreData

class FavCollectionViewController: UICollectionViewController {

   
    var favNoticias:NSFetchedResultsController<NoticiaDB> = {
        let fetchRequest:NSFetchRequest<NoticiaDB> = NoticiaDB.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "fav = %@", NSNumber(booleanLiteral: true))
        let ordenID = NSSortDescriptor(key: #keyPath(NoticiaDB.idNoticia), ascending: true)
        fetchRequest.sortDescriptors = [ordenID]
        let consulta = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ctx, sectionNameKeyPath: nil, cacheName: nil)
        return consulta
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadFavoritos()
    }
    
    func loadFavoritos() {
       
        do {
            try favNoticias.performFetch()
            collectionView.reloadData()
        } catch {
            print("Error al cargar favoritos")
        }
    }
    
  
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return favNoticias.sections?.count ?? 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return favNoticias.sections?[section].numberOfObjects ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favCell", for: indexPath) as! FavCollectionViewCell
        let dato = favNoticias.object(at: indexPath)
        cell.favTitle.text = dato.titleNoticia
        cell.favAutor.text = "✍\(dato.authorNoticia?.nameAuthor ?? "")"
        
        if let imageData = dato.imagenDataNoticia {
            cell.favImage.image = UIImage(data: imageData)!
        } else {
            getImage(url: dato.imagenNoticia!) { (image) in
                let visible = collectionView.indexPathsForVisibleItems
                if visible.contains(indexPath) {
                    cell.favImage.image = image
                }
                dato.imagenDataNoticia = image.pngData()!
                saveContext()
            }
        }
        //This creates the shadows and modifies the cards a little bit
        cell.contentView.layer.cornerRadius = 4.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cell.layer.shadowRadius = 4.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let origen = sender as? FavCollectionViewCell,
        let destino = segue.destination as? DetalleViewController,
        let indexPath = collectionView.indexPath(for: origen) else {
            return
        }
        
        let dato = favNoticias.object(at: indexPath)
        destino.detallePost = dato
        
    }
    
    

}
