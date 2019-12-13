//
//  TaskManager.swift
//  LectorNoticias
//
//  Created by saqib on 08/09/2019.
//  Copyright © 2019 saqib. All rights reserved.
//
import UIKit
class ConnectionManager {
    static let shared = ConnectionManager()
    
    let session = URLSession(configuration: .default)
    
    typealias completionHandler = (Data?, URLResponse?, Error?) -> Void
    
    var tasks = [URL: [completionHandler]]()
    
    func dataTask(with url: URL, completion: @escaping completionHandler) {
        if tasks.keys.contains(url) {
            DispatchQueue.main.async {
                self.tasks[url]?.append(completion)
            }
            
        } else {
            tasks[url] = [completion]
            let _ = session.dataTask(with: url, completionHandler: { [weak self](data, response, error) in
                DispatchQueue.main.async {
                    guard let completionHandlers = self?.tasks[url] else { return }
                    for handler in completionHandlers {
                        
                        handler(data, response, error)
                    }
                }
                
                
                
            }).resume()
        }
    }
}
