//
//  Origin.swift
//  RickAndMortyApp
//
//  Created by Paul Flores on 26/09/25.
//

import Foundation

struct Location: Codable, Identifiable {
    let id: Int
    let name: String
    let type: String
    let dimension: String
    let residents: [URL]
    let url: String
    let created: String
}
