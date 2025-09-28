//
//  PersistenceController.swift
//  RickAndMortyApp
//
//  Created by Paul Flores on 27/09/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = true) {
        container = NSPersistentContainer(name: "DatabaseModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error loading Core Data: \(error)")
            }
        }
    }
}

