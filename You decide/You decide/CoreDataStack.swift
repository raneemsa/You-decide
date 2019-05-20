//
//  CoreDataStack.swift
//  Virtual Tourist
//
//  Created by Raneem on 5/16/19.
//  Copyright © 2019 Raneem. All rights reserved.
//

import CoreData



struct CoreDataStack {
    

    
    private let model: NSManagedObjectModel
    internal let coordinator: NSPersistentStoreCoordinator
    private let modelURL: URL
    internal let databaseUrl: URL
    internal let persistingContext: NSManagedObjectContext
    internal let backgroundContext: NSManagedObjectContext
    let context: NSManagedObjectContext
    
    
    
    static func shared() -> CoreDataStack {
        struct share {
            
            static var shared = CoreDataStack(modelName: "Virtual_Tourist")!
        }
        return share.shared
    }
    
    
    
    init?(modelName: String) {
        
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
        
            return nil
        }
        
        self.modelURL = modelURL
        
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            return nil
        }
        
        self.model = model
        
        
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = coordinator
        
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = persistingContext
        
        
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context
        
        
        let manager = FileManager.default
        
        guard let docUrl = manager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to reach the folder")
            return nil
        }
        
        self.databaseUrl = docUrl.appendingPathComponent("model.sqlite")
        
       
        let options = [
            NSInferMappingModelAutomaticallyOption: true,
            NSMigratePersistentStoresAutomaticallyOption: true
        ]
        
        do {
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: databaseUrl, options: options as [NSObject : AnyObject]?)
        } catch {
            print("unable to add at \(databaseUrl)")
        }
    }
    
    
    
    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options : [NSObject:AnyObject]?) throws {
        
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: databaseUrl, options: nil)
        
    }
    
    
    func fetchPhotos(_ predicate: NSPredicate? = nil, entityName: String, sorting: NSSortDescriptor? = nil) throws -> [Photo]? {
        let fetched = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetched.predicate = predicate
        if let sorting = sorting {
            fetched.sortDescriptors = [sorting]
        }
        guard let photo = try context.fetch(fetched) as? [Photo] else {
            return nil
        }
        return photo
    }
    
    
    
    func fetchPin(_ predicate: NSPredicate, entityName: String, sorting: NSSortDescriptor? = nil) throws -> Pin? {
        let fetched = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetched.predicate = predicate
        if let sorting = sorting {
            fetched.sortDescriptors = [sorting]
        }
        guard let pin = (try context.fetch(fetched) as! [Pin]).first else {
            return nil
        }
        return pin
    }
    
    
    func fetchAllPins(_ predicate: NSPredicate? = nil, entityName: String, sorting: NSSortDescriptor? = nil) throws -> [Pin]? {
        let fetched = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetched.predicate = predicate
        if let sorting = sorting {
            fetched.sortDescriptors = [sorting]
        }
        guard let pin = try context.fetch(fetched) as? [Pin] else {
            return nil
        }
        return pin
    }
    
}





internal extension CoreDataStack  {
    
    func dropAllData() throws {
        
        
        try coordinator.destroyPersistentStore(at: databaseUrl, ofType:NSSQLiteStoreType , options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: databaseUrl, options: nil)
    }
}



extension CoreDataStack {
    
    
    func autoSave(_ delayInSeconds : Int) {
        
        if delayInSeconds > 0 {
            do {
                try saveContext()
            } catch {
                print("Error while autosaving")
            }
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.autoSave(delayInSeconds)
            }
        }
    }
    
    func saveContext() throws {
        context.performAndWait() {
            
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    print("Error while saving main context: \(error)")
                }
                
                self.persistingContext.perform() {
                    do {
                        try self.persistingContext.save()
                    } catch {
                        print("Error while saving persisting context: \(error)")
                    }
                }
            }
        }
    }
    
}
