//
//  CoreDataStack.swift
//  Hard_MAD
//
//  Created by dark type on 23.05.2025.
//

import CoreData
import Foundation

final class CoreDataStack: Sendable {
    let persistentContainer: NSPersistentContainer
    
    init(modelName: String = "Model") {
        persistentContainer = NSPersistentContainer(name: modelName)
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("CoreData failed to load: \(error), \(error.userInfo)")
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    func save() throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try context.save()
        }
    }
}
