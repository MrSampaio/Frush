//
//  CoreDataManager.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 13/08/26.
//

//import Foundation
//import CoreData

//class CoreDataManager{
//    let persistentContainer: NSPersistentContainer
//    static let shared = CoreDataManager()
//    
//    var viewContext: NSManagedObjectContext{
//        return self.persistentContainer.viewContext
//    }
//    
//    init(){
//        self.persistentContainer = NSPersistentContainer(name: "Database")
//        self.persistentContainer.loadPersistentStores { (description, error) in
//            if let error = error{
//                print("Error loading persistent stores: \(error)")
//            }
//        }
//        
//        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
//        
//        
//        // atualiza automaticamente os possíveis novos atributos do banco
//        let description = persistentContainer.persistentStoreDescriptions.first
//        description?.shouldInferMappingModelAutomatically = true
//        description?.shouldMigrateStoreAutomatically = true
//    }
//    
//}

//
//  CoreDataManager.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 13/08/26.
//

//import Foundation
//import CoreData
//
//class CoreDataManager {
//    let persistentContainer: NSPersistentContainer
//    static let shared = CoreDataManager()
//    
//    var viewContext: NSManagedObjectContext {
//        return self.persistentContainer.viewContext
//    }
//    
//    init() {
//        self.persistentContainer = NSPersistentContainer(name: "Database")
//        
//        // Configurar para usar memória RAM
//        let description = NSPersistentStoreDescription()
//        description.type = NSInMemoryStoreType  // ← Aqui é a mágica
//        self.persistentContainer.persistentStoreDescriptions = [description]
//        
//        self.persistentContainer.loadPersistentStores { (description, error) in
//            if let error = error {
//                print("Error loading persistent stores: \(error)")
//            } else {
//                print("Core Data loaded in memory ✅")
//            }
//        }
//        
//        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
//    }
//}

