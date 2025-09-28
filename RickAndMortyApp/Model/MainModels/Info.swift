//
//  Info.swift
//  RickAndMortyApp
//
//  Created by Paul Flores on 26/09/25.
//

import Foundation

struct Info: Codable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}
