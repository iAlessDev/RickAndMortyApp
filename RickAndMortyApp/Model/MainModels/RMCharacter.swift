//
//  Character.swift
//  RickAndMortyApp
//
//  Created by Paul Flores on 26/09/25.
//

import Foundation

struct RMCharacter: Codable, Identifiable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: Origin
    let location: Origin
    let image: String
    let episode: [String]
    let url: String
    let created: String
    var isFavorite: Bool = false
    
    
    enum CodingKeys: String, CodingKey {
        case id, name, status, species, type, gender, origin, location, image, episode, url, created
    }
}
