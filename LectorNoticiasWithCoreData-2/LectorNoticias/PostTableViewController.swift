//
//  PostTableViewController.swift
//  LectorNoticias
//
//  Created by saqib on 29/08/2019.
//  Copyright © 2019 saqib. All rights reserved.
//

import UIKit
import WebKit
import CoreData
var notifierVar = 0 {
    didSet {
        if notifierVar == 3 {
            print("All data loaded")
            NotificationCenter.default.post(Notification(name: .init("completed")))
            notifierVar = 0
        }
    }
}


class PostTableViewController: UITableViewController,UITabBarControllerDelegate,UISearchResultsUpdating {
    
    //var posts = [NoticiaDB]()
    var indicator = UIActivityIndicatorView()
    var posts:NSFetchedResultsController<NoticiaDB> = {
        let fetchRequest:NSFetchRequest<NoticiaDB> = NoticiaDB.fetchRequest()
        let ordenID = NSSortDescriptor(key: #keyPath(NoticiaDB.idNoticia), ascending: true)
        fetchRequest.sortDescriptors = [ordenID]
        let consulta = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ctx, sectionNameKeyPath: nil, cacheName: nil)
        return consulta
    }()
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self
        activityIndicator()
        indicator.startAnimating()
        loadNoticiasDB()
        refresher()
        NotificationCenter.default.addObserver(self, selector: #selector(reloading), name: .init(rawValue: "completed"), object: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Introduzca noticia a buscar"
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        
        self.clearsSelectionOnViewWillAppear = false
    }
    
    
    //creates and assigns values,actions to activity indicator
    func activityIndicator() {
        indicator.style = UIActivityIndicatorView.Style.whiteLarge
        indicator.color = .black
        indicator.center = CGPoint(x: self.view.center.x, y: (self.view.center.y) - 120)
        indicator.hidesWhenStopped = true
        self.view.addSubview(indicator)
    }
    
    //creates and assigns values,actions to refresher
    func refresher() {
        let refresher = UIRefreshControl()
        refresher.tintColor = .black
        refresher.addTarget(self, action: #selector(loadNoticiasLocal), for: .valueChanged)
        self.refreshControl = refresher
    }
    
    //function to fetch data from database
    func fetchData(completion:(Bool) -> Void) {
        do {
            try posts.performFetch()
            completion(true)
            print("data fetch correctly")
            
        } catch {
            completion(false)
            print("Not able to fetch data")
        }
        
    }
    
    //saves the context so changed values are updated in database
    @objc func reloading() {
        ConnectionManager.shared.tasks.removeAll()
        fetchData { (complete) in
            if complete {
                saveContext()
                indicator.stopAnimating()
                print("loading the data after fetch")
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    func reloadViewAndFetch() {
        do {
            try posts.performFetch()
        } catch {
            print("Failed at fetch")
        }
        self.tableView.reloadData()
        
    }
    
    @objc func loadNoticiasLocal() {
        loadNoticiasDB()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
         return posts.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
         return posts.sections?[section].numberOfObjects ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath) as! PostTableViewCell
        
        let dato = posts.object(at: indexPath)
        if dato.fav {
            cell.backgroundColor = .yellow
        } else {
            cell.backgroundColor = .clear
        }
        cell.postExcerpt.text = dato.excerptNoticia
        cell.postTitle.text = dato.titleNoticia
        
        cell.postAuthor.text = dato.authorNoticia?.nameAuthor
        let date = dato.dateNoticia
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let formattedDate = format.string(from: date!)
        let categoryArray = Array(dato.categoryNoticia!) as! [CategoryDB]
        //joinning all categories
        let joined = categoryArray.map {$0.nameCategory!}.joined(separator: ",")
        cell.postCategory.text = joined
        cell.postFecha.text = "📅 \(formattedDate)"
        cell.postAuthor.text = "🖋 \(dato.authorNoticia?.nameAuthor ?? "")"
        if let imageData = dato.imagenDataNoticia {
            cell.postImage.image = UIImage(data: imageData)!
        } else {
            getImage(url: dato.imagenNoticia!) { (image) in
                if let visible = tableView.indexPathsForVisibleRows, visible.contains(indexPath){
                   cell.postImage.image = image
                }
                dato.imagenDataNoticia = image.pngData()!
                saveContext()
            }
        }
     
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
           guard let destino = segue.destination as? DetalleViewController,
                let origen = sender as? PostTableViewCell,
                let indexPath = tableView.indexPath(for: origen) else {
                    return
        }
            let dato = posts.object(at: indexPath)
            destino.detallePost = dato
            
    }
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let dato = posts.object(at: indexPath)
        let action = UIContextualAction(style: .normal, title: "Favorito") {
            action, view, handler in
            dato.fav.toggle()
            saveContext()
            let cell = tableView.cellForRow(at: indexPath)
            if dato.fav {
                cell?.backgroundColor = .yellow
            } else {
                cell?.backgroundColor = .clear
            }
            handler(true)
        }
        action.image = UIImage(named: "heart")
        if !dato.fav {
            action.backgroundColor = .green
        } else {
            action.backgroundColor = .red
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    //button for sort actions
    @IBAction func ordenarButton(_ sender: UIBarButtonItem) {
        ordenar()
    }
    
    //function for sorting
    func ordenar(_ barButtonItem:UIBarButtonItem? = nil) {
        let alertaOrden = UIAlertController(title: "Ordenación", message: "Seleccione el tipo de orden de las noticias", preferredStyle: .actionSheet)
        let accionAscendente = UIAlertAction(title: "Recientes", style: .default) { [weak self] _ in
            let sectionID = NSSortDescriptor(key: #keyPath(NoticiaDB.dateNoticia), ascending: false)
            self?.posts.fetchRequest.sortDescriptors = [sectionID]
            self?.reloading()
        }
        let accionDescendente = UIAlertAction(title: "Descendente", style: .default) { [weak self] _ in
            let sectionID = NSSortDescriptor(key: #keyPath(NoticiaDB.dateNoticia), ascending: true)
            self?.posts.fetchRequest.sortDescriptors = [sectionID]
            self?.reloading()
        }
        let accionDefecto = UIAlertAction(title: "Por defecto", style: .default) {
            [weak self] _ in
            let sectionID = NSSortDescriptor(key: #keyPath(NoticiaDB.idNoticia), ascending: true)
            self?.posts.fetchRequest.sortDescriptors = [sectionID]
            self?.reloading()
        }
        alertaOrden.addAction(accionAscendente)
        alertaOrden.addAction(accionDescendente)
        alertaOrden.addAction(accionDefecto)
        
        if let popOver = alertaOrden.popoverPresentationController {
            popOver.barButtonItem = barButtonItem
        }
        
        present(alertaOrden, animated: true, completion: nil)
    }
   
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        if text.isEmpty {
            posts.fetchRequest.predicate = nil
        } else {
            posts.fetchRequest.predicate = NSPredicate(format: "titleNoticia CONTAINS[c] %@ OR excerptNoticia CONTAINS[c] %@", text, text)
        }
        reloadViewAndFetch()
    }
}
