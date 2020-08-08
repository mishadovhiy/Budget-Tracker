//
//  AppDelegate.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 09.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func downloadFromDB() {
        let load = LoadFromDB()
        DispatchQueue.main.async {
            load.Transactions { (loadedData) in
                print("loaded \(loadedData.count) transactions from DB")
                var dataStruct: [TransactionsStruct] = []
                for i in 0..<loadedData.count {
                    
                    let value = loadedData[i][3]
                    let category = loadedData[i][1]
                    let date = loadedData[i][2]
                    let comment = loadedData[i][4]
                    dataStruct.append(TransactionsStruct(value: value, category: category, date: date, comment: comment))
                }
                appData.saveTransations(dataStruct)
                //self.filter()
            }
        }
        
        DispatchQueue.main.async {
            load.Categories { (loadedData) in
                print("loaded \(loadedData.count) Categories from DB")
                var dataStruct: [CategoriesStruct] = []
                for i in 0..<loadedData.count {
                    
                    let name = loadedData[i][1]
                    let purpose = loadedData[i][2]
                    dataStruct.append(CategoriesStruct(name: name, purpose: purpose))
                }
                appData.saveCategories(dataStruct)
            }
        }
        
        
        appData.defaults.setValue(appData.filter.getToday(appData.filter.filterObjects.currentDate), forKey: "LastLoad")
        
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let today = appData.filter.getToday(appData.filter.filterObjects.currentDate)
         let lastLoad = appData.defaults.value(forKey: "LastLoad") as? String ?? ""
         
         if today != lastLoad {
             downloadFromDB()
         }
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    @available(iOS 13.0, *)
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        
        let container = NSPersistentCloudKitContainer(name: "Budget_Tracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        
        return container
    }()
    
    lazy var persistentContainer2: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Budget_Tracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if #available(iOS 13.0, *) {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        } else {
            let context = persistentContainer2.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }

}

