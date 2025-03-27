//
//  CoreDataService.swift
//  LucidWeatherApp
//
//  Created by Mario Ban on 26.03.2025..
//

import Foundation
import CoreData

class CoreDataService {
    static let shared = CoreDataService()
    let persistentContainer: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "LucidWeatherApp")
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
