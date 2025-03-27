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
    let persistantContainer: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        return persistantContainer.viewContext
    }
    
    private init() {
        persistantContainer = NSPersistentContainer(name: "LucidWeatherApp")
        persistantContainer.loadPersistentStores { (description, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
