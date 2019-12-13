import UIKit
import WebKit
import Foundation
import CoreData

struct Post:Codable {
    
    let id:Int
    let date:Date
    let link:URL
    let title:Title
    let author:Int
    let categories:[Int]
    let content:Content
    let excerpt:Excerpt
    let jetpack_featured_media_url:URL
}


struct Title:Codable {
    
    let rendered:String
}

struct Content:Codable {
    
    let rendered:String
}

struct Excerpt:Codable {
    
    let rendered:String
}
struct Category:Codable {
    let name:String
    let id:Int
}
struct Author:Codable {
    let name:String
    let id:Int
}


extension DateFormatter {
    static let iso8601Full:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }() }


func getData(url:URL, callback:@escaping (Data) -> Void) {
    
        ConnectionManager.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                if let error = error {
                    print("Error de red \(error)")
                }
                return
            }
            if response.statusCode == 200 {
                callback(data)
            } else {
                print("Estado devuelto: \(response.statusCode)")
            }
        
        
        }
}



func getPosts(callback: @escaping ([Post]) -> Void)  {
    
    let url = URL(string: "https://applecoding.com/wp-json/wp/v2/posts?per_page=20")
    
    getData(url: url!) { (data) in
        
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                let result = try decoder.decode([Post].self, from: data)
                callback(result)
            } catch {
                print("Cant get the post. Error: \(error)")
            }
        
        
        
    }
    
}


func getAutor(id: Int, callback: @escaping (Author) -> Void){
    let url = URL(string: "https://applecoding.com/wp-json/wp/v2/users/\(id)")
        
        getData(url: url!) { (data) in
            
            do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
            let result = try decoder.decode(Author.self, from: data)
            callback(result)
            } catch {
            print("Cant get the post. Error: \(error)")
            }
            
            
            
        }
}

func getCategory(id: Int, callback: @escaping (Category) -> Void){
    let url = URL(string: "https://applecoding.com/wp-json/wp/v2/categories/\(id)")
    
    getData(url: url!) { (data) in
        
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                let result = try decoder.decode(Category.self, from: data)
                callback(result)
            } catch {
                print("Cant get the post. Error: \(error)")
            }
        
        
        
    }
}


func getImage(url:URL, callback:@escaping (UIImage) -> Void) {
    getData(url: url) { data in
        if let imagen = UIImage(data: data) {
            callback(imagen)
        } else {
            print("Los datos de imagen no se han validado")
        }
    }
}

//func saveImage(id:Int, image:UIImage) {
//    guard let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first, let imagenData = image.pngData() else {
//        return
//    }
//    let ruta = folder.appendingPathComponent("imagen_\(id)").appendingPathExtension("png")
//    try? imagenData.write(to: ruta, options: .atomicWrite)
//}
//
//func loadImage(id:Int) -> UIImage? {
//    guard let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//        return nil
//    }
//    let ruta = folder.appendingPathComponent("imagen_\(id)").appendingPathExtension("png")
//    if let data = try? Data(contentsOf: ruta) {
//        return UIImage(data: data)
//    }
//    return nil
//}




func loadNoticiasDB() {
    var authorCounter = 0
    var catCounter = 0
    print("outside load noticias")
    getPosts { (posArray) in
        print("inside get posts")
        let totalCats = posArray.map{$0.categories}.flatMap{$0}
        posArray.forEach { pos in
                //loading the posts
                //Creates a fetch request for PostDB
                let fetchRequest:NSFetchRequest<NoticiaDB> = NoticiaDB.fetchRequest()
                //sets the predicate to fetch data, in this case it is something like
                //select from postDB where id = post.id
                fetchRequest.predicate = NSPredicate(format: "idNoticia = %@", NSNumber(value: pos.id))
                do {
                let result = try ctx.count(for: fetchRequest)
                    if result == 0 {
                        let newNoticia = NoticiaDB(context: ctx)
                        newNoticia.idNoticia = Int64(pos.id)
                        newNoticia.linkNoticia = pos.link
                        newNoticia.excerptNoticia = pos.excerpt.rendered.html2String
                        newNoticia.contentNoticia = pos.content.rendered
                        newNoticia.titleNoticia = pos.title.rendered.html2String
                        newNoticia.dateNoticia = pos.date
                        newNoticia.imagenNoticia = pos.jetpack_featured_media_url
                        
                        
                        
                        let fetchRequestAuthor:NSFetchRequest<AuthorDB> = AuthorDB.fetchRequest()
                        fetchRequestAuthor.predicate = NSPredicate(format: "idAuthor = %@", NSNumber(value: pos.author))
                        let result2 = try ctx.fetch(fetchRequestAuthor)
                        if result2.count == 0 {
                            getAutor(id: pos.author, callback: { (author) in
                                let newAuthor = AuthorDB(context: ctx)
                                newAuthor.idAuthor = Int64(author.id)
                                newAuthor.nameAuthor = author.name
                                newNoticia.authorNoticia = newAuthor
                                authorCounter+=1
                                print("onlineAuthor:\(authorCounter)")
                                if authorCounter == posArray.count {
                                    notifierVar+=1
                                }
                            })
                            
                        } else {
                            newNoticia.authorNoticia = result2.first
                            authorCounter+=1
                            print("offlineAuthor:\(authorCounter)")
                            if authorCounter == posArray.count {
                                notifierVar+=1
                            }
                        }
                        //loading the categories
                        for cat in pos.categories {
                            let fetchRequestCategory:NSFetchRequest<CategoryDB> = CategoryDB.fetchRequest()
                            fetchRequestAuthor.predicate = NSPredicate(format: "idCategory = %@", NSNumber(value: cat))
                            let result3 = try ctx.fetch(fetchRequestCategory)
                            if result3.count == 0 {
                                getCategory(id: cat, callback: { (cate) in
                                    let newCategory = CategoryDB(context: ctx)
                                    newCategory.idCategory = Int64(cate.id)
                                    newCategory.nameCategory = cate.name
                                    newNoticia.addToCategoryNoticia(newCategory)
                                    catCounter += 1
                                    print("onlineCategory:\(catCounter)")
                                    if catCounter == totalCats.count {
                                        notifierVar += 1
                                    }
                                })
                                
                            } else {
                                newNoticia.addToCategoryNoticia(result3.first!)
                                catCounter += 1
                                print("offlineCategory:\(catCounter)")
                                if catCounter == totalCats.count {
                                    notifierVar += 1
                                }
                            }
                        }
                        
                       } else {
                        authorCounter+=1
                        print("ALAuthor: \(authorCounter)")
                        if authorCounter == posArray.count {
                            notifierVar+=1
                        }
                        catCounter += pos.categories.count
                        print("ALCategory: \(catCounter)")
                        if catCounter == totalCats.count {
                            notifierVar+=1
                        }
                        }
                } catch {
                    print("Error while saving core data")
                }
        }
        notifierVar += 1
        
    }
}

