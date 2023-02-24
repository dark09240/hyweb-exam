//
//  CoreDataService.swift
//  hywebr-exam
//
//  Created by Dong on 2023/2/23.
//

import Foundation
import CoreData

class CoreDataService<T: NSFetchRequestResult> {
    
    //MARK: - Variables
    private let entityName: String
    private let fetchedResultsController: NSFetchedResultsController<T>
    private let persistentContainer: NSPersistentContainer
    
    //MARK: - Get
    func get(_ predicate: NSPredicate? = nil) -> [T] {
        fetchedResultsController.fetchRequest.predicate = predicate
        do {
            try fetchedResultsController.performFetch()
            return fetchedResultsController.fetchedObjects ?? []
        }catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    //MARK: - New
    func new() -> T? {
        let context = persistentContainer.viewContext
        if let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) {
            return NSManagedObject(entity: entity, insertInto: context) as? T
        }else {
            return nil
        }
    }
    
    //MARK: - Save
    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: - Init
    init(entityName: String, databaseName: String, sortKey: String) {
        self.entityName = entityName
        
        persistentContainer = NSPersistentContainer(name: databaseName)
        persistentContainer.loadPersistentStores(completionHandler: {description, error in
            if let error {
                assertionFailure(error.localizedDescription)
            }
        })
        
        let request = NSFetchRequest<T>(entityName: entityName)
        request.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: true)]
        let context = persistentContainer.viewContext
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
}
