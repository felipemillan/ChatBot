//
//  CoreDataManager.swift
//  ChatBot
//
//  Created by Alexandr on 16.09.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

import UIKit
import CoreData

class CoreDataStack: NSObject {

    static let shared = CoreDataStack()
    
    var managedObjectContext: NSManagedObjectContext
    var fetchedItems = 0
    
    private override  init() {
        guard let modelURL = Bundle.main.url(forResource: "DataModel", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls[urls.endIndex-1]

        let storeURL = docURL.appendingPathComponent("DataModel.sqlite")
        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
    }
    
    func fetch(amount: Int?, from user: User) -> [Message] {
        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        let predicate = NSPredicate(format: "owner == %@", user)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            var index = 0
            var messages = [Message]()
            for message in result {
                index += 1
                if index > fetchedItems {
                    messages.append(message)
                }
                if amount != nil && index == (fetchedItems + amount!) {
                    break
                }
            }
            fetchedItems = index
            return messages
        }
        catch {
            fatalError("Failed to fetch person: \(error)")
        }
    }
    
    func save(msg: String, id: String, user: User) {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Message", into: managedObjectContext) as! Message
        entity.message = msg
        entity.displayName = id
        entity.senderId = id
        entity.date = NSDate()
        entity.owner = user
        user.addToMessages(entity)
        do {
            try managedObjectContext.save()
        } catch  {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func save(user: String) {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "User", into: managedObjectContext) as! User
        entity.name = user
        entity.money = 0
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func fetch(user: String) -> User? {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let predicate = NSPredicate(format: "name == %@", user)
        fetchRequest.predicate = predicate
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            
            if result.count == 0 {
                return nil
            }
            return result.first!
        }
        catch {
            fatalError("Failed to fetch person: \(error)")
        }
    }
    
    func save(category: String, cost: Int, user: User) {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Category", into: managedObjectContext) as! Category
        entity.name = category
        entity.owner = user
        entity.cost = Int64(cost)
        user.addToCategories(entity)
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func fetchCategories(user: User) -> [Category] {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        let predicate = NSPredicate(format: "owner == %@", user)
        fetchRequest.predicate = predicate
        
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            return result
        }
        catch {
            fatalError("Failed to fetch person: \(error)")
        }
    }
    
    func fetch(category: String, user: User) -> Category? {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        let predicate1 = NSPredicate(format: "owner == %@", user)
        let predicate2 = NSPredicate(format: "name == %@", category)
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [predicate1, predicate2])
        fetchRequest.predicate = compound
        
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            
            return result.first
        }
        catch {
            fatalError("Failed to fetch person: \(error)")
        }
    }
    
}
