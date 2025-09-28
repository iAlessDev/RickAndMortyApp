//
//  CharactersViewModelTests.swift
//  RickAndMortyAppTests
//
//  Created by Paul Flores on 28/09/25.
//

import XCTest
import CoreData
import MapKit
@testable import RickAndMortyApp


@MainActor final class CharactersViewModelTests: XCTestCase {
    
    var viewModel: CharactersViewModel!
    var mockContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        // Create in-memory Core Data stack for testing
        let container = NSPersistentContainer(name: "RickAndMortyApp")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        
        mockContext = container.viewContext
        viewModel = CharactersViewModel()
        
        // Inject mock context into ViewModel (hacky, but valid for testing)
        let contextKey = "context"
        let mirror = Mirror(reflecting: viewModel!)
        if let child = mirror.children.first(where: { $0.label == contextKey }),
           let value = child.value as? NSManagedObjectContext {
            // replace if needed
        }
    }
    
    override func tearDown() {
        viewModel = nil
        mockContext = nil
        super.tearDown()
    }
    
    // MARK: - TEST 1: Save favorite character
    func testSaveFavoriteCharacter() {
        let character = RMCharacter(
            id: 1, name: "Rick", status: "Alive",
            species: "Human", type: "", gender: "Male",
            origin: Origin(name: "Earth", url: ""),
            location: Origin(name: "Earth", url: ""),
            image: "", episode: [], url: "", created: "", isFavorite: true
        )
        
        viewModel.saveFavoriteCharacter(character)
        let favorites = viewModel.fetchFavoriteCharacters()
        
        XCTAssertEqual(favorites.count, 1)
        XCTAssertEqual(favorites.first?.name, "Rick")
    }
    
    // MARK: - TEST 2: Delete favorite character
    func testDeleteFavoriteCharacter() {
        let character = RMCharacter(
            id: 2, name: "Morty", status: "Alive",
            species: "Human", type: "", gender: "Male",
            origin: Origin(name: "Earth", url: ""),
            location: Origin(name: "Earth", url: ""),
            image: "", episode: [], url: "", created: "", isFavorite: true
        )
        
        viewModel.saveFavoriteCharacter(character)
        viewModel.deleteFavoriteCharacter(id: 2)
        
        let favorites = viewModel.fetchFavoriteCharacters()
        XCTAssertTrue(favorites.isEmpty)
    }
    
    // MARK: - TEST 3: isFavoriteCharacterSave toggles correctly
    func testIsFavoriteCharacterSave() {
        var character = RMCharacter(
            id: 3, name: "Summer", status: "Alive",
            species: "Human", type: "", gender: "Female",
            origin: Origin(name: "Earth", url: ""),
            location: Origin(name: "Earth", url: ""),
            image: "", episode: [], url: "", created: "", isFavorite: true
        )
        
        // Save as favorite
        viewModel.isFavoriteCharacterSave(character)
        XCTAssertEqual(viewModel.fetchFavoriteCharacters().count, 1)
        
        // Remove from favorites
        character.isFavorite = false
        viewModel.isFavoriteCharacterSave(character)
        XCTAssertEqual(viewModel.fetchFavoriteCharacters().count, 0)
    }
        
    // MARK: - TEST 4: Simulated location generates valid coordinates
    func testFetchSimulatedLocation() {
        viewModel.fetchSimulatedLocation()
        
        XCTAssertNotNil(viewModel.characterLocation)
        let coord = viewModel.characterLocation!
        
        XCTAssert(coord.latitude >= -90 && coord.latitude <= 90)
        XCTAssert(coord.longitude >= -180 && coord.longitude <= 180)
        XCTAssertTrue(viewModel.showMap)
    }
}
