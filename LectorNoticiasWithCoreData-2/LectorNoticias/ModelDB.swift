import UIKit
import CoreData

var persistentContainer:NSPersistentContainer = {
    let container = NSPersistentContainer(name: "ModelDB2")
    container.loadPersistentStores { store, error in
        if let error = error as NSError? {
            fatalError("No se ha podido abrir la base de datos")
        }
    }
    return container
}()

var ctx:NSManagedObjectContext {
    return persistentContainer.viewContext
}

func saveContext() {
    DispatchQueue.main.async {
        if ctx.hasChanges {
            do {
                try ctx.save()
            } catch {
                print("Error en el commit \(error)")
            }
        }
    }
}

