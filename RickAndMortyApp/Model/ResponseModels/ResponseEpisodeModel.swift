//
//  ResponseEpisodeModel.swift
//  RickAndMortyApp
//
//  Created by Paul Flores on 28/09/25.
//

import Foundation
import Combine

struct ResponseEpisodeModel: Codable {
    let info: Info
    let results: [RMEpisode]
}
