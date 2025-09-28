//
//  Episode.swift
//  RickAndMortyApp
//
//  Created by Paul Flores on 26/09/25.
//

import Foundation

struct RMEpisode: Codable, Identifiable {
    let id: Int
    let name: String
    let air_date: String
    let episode: String
    let characters: [String]
    let url: String
    let created: String
    var isFavorite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, name, air_date, episode, characters, url, created
    }
}
