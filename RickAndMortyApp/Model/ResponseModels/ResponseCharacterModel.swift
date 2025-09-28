//
//  ResponseCharacterModel.swift
//  RickAndMortyApp
//
//  Created by Paul Flores on 26/09/25.
//

import Foundation
import Combine

struct ResponseCharacterModel: Codable {
    let info: Info
    let results: [RMCharacter]
}

