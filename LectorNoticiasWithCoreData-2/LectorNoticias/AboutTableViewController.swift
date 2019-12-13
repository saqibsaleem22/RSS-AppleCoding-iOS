//
//  AboutTableViewController.swift
//  LectorNoticias
//
//  Created by saqib on 01/09/2019.
//  Copyright © 2019 saqib. All rights reserved.
//

import UIKit

class AboutTableViewController: UITableViewController {

    @IBOutlet weak var versionApp: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        versionApp.text = "verison \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")" 
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    @IBAction func facbookAction(_ sender: UIButton) {
        let link = "https://facebook.com/applecoding"
        openLink(for: link)
    }
    
    
    @IBAction func twitterAction(_ sender: UIButton) {
        let link = "https://twitter.com/apple_coding"
        openLink(for: link)
    }
    
    @IBAction func instaAction(_ sender: UIButton) {
        let link = "https://www.instagram.com/apple_coding/"
        openLink(for: link)
    }
    
    func openLink(for link:String) {
        let url = URL(string: link)
        if let url = url {
            UIApplication.shared.open(url, options: .init())
        }
        
    }
    
}
