//
//  CoreDataDBManager.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 13.10.2023.
//

import Foundation
import CoreData

struct GeneralEntityStruct {
    let db:Data
    static func create(db:GeneralEntity) -> GeneralEntityStruct {
        return .init(db: db.data ?? .init())
    }
}

struct CoreDataDBManager {
    enum Entities:String {
        case general = "GeneralEntity"
    }
    
    private let persistentContainer:NSPersistentContainer
    private let context:NSManagedObjectContext
    private let appDelegate:AppDelegate
    
    init(persistentContainer: NSPersistentContainer,
         appDelegate:AppDelegate) {
        self.persistentContainer = persistentContainer
        self.context = persistentContainer.viewContext
        self.appDelegate = appDelegate
    }
    
    static var dataHolder:GeneralEntityStruct?
    
    func fetch(_ entitie:Entities) -> GeneralEntity? {
        let results = self.fetchRecordsForEntity(entitie, inManagedObjectContext: context)
        if let transactions = (results.filter({
            return $0 is GeneralEntity
        }) as? [GeneralEntity])?.first {
            return transactions
        } else {
            return nil
        }
        
    }
    

    func update(_ new:GeneralEntityStruct) {
        if let old = fetch(.general) {
            old.data = new.db
            appDelegate.saveContext()
        } else {
            let _: GeneralEntity = .create(entity: context, transaction: new)
            appDelegate.saveContext()
        }
    }
    
    private func fetchRecordsForEntity(_ entity:Entities, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)

        var result = [NSManagedObject]()

        do {
            let records = try managedObjectContext.fetch(fetchRequest)

            if let records = records as? [NSManagedObject] {
                result = records
            }

        } catch {
            print("Unable to fetch managed objects for entity \(entity.rawValue).")
        }

        return result
    }
    
    
}

extension GeneralEntity {
    static func create(entity:NSManagedObjectContext, transaction:GeneralEntityStruct) -> GeneralEntity {
        let new = GeneralEntity(context: entity)
        new.data = transaction.db
        return new
    }
        
}



