//
//  FavoriteCharacterViewModel.swift
//  RickAndMortyApp
//
//  Created by Paul Flores on 27/09/25.
//

import Foundation
import CoreData
import Combine

class FavoriteCharacterViewModel: ObservableObject {
    private let context = PersistenceController.shared.container.viewContext
    @Published var characters: [CDCharacter] = []
    
    
    func fetchFavoriteCharacters() {
        let request: NSFetchRequest<CDCharacter> = CDCharacter.fetchRequest()
        do {
            let favorites: [CDCharacter] = try context.fetch(request)
            for fav in favorites {
                print("id: \(fav.id), name: \(fav.name ?? "nil")")
            }

            characters = favorites
        } catch {
            print("Error fetching: \(error)")
        }
    }
    
    func deleteFavoriteCharacter(id: Int) {
        let request: NSFetchRequest<CDCharacter> = CDCharacter.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", Int64(id))

        do {
            let results = try context.fetch(request)
            for obj in results { context.delete(obj) }
            if context.hasChanges { try context.save() }
            print("🗑️ Character(s) with id \(id) deleted")
            fetchFavoriteCharacters()
        } catch {
            print("CoreData delete error:", error)
        }
    }
    
    
}

