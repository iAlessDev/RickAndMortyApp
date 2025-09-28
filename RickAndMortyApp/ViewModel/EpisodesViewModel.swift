//
//  FavoriteEpisodesViewModel.swift
//  RickAndMortyApp
//
//  Created by Paul Flores on 28/09/25.
//

import Foundation
import CoreData
import Combine

class EpisodeViewModel: ObservableObject {
    private let context = PersistenceController.shared.container.viewContext
    @Published var episodes: [RMEpisode] = []
    
    // MARK: - Networking
    private let baseURL = "https://rickandmortyapi.com/api"
        
    func fetchEpisodes(for character: RMCharacter) async {
        do {
            for episodeURL in character.episode {
                guard let url = URL(string: episodeURL) else { continue }
                let (data, _) = try await URLSession.shared.data(from: url)
                var episode = try JSONDecoder().decode(RMEpisode.self, from: data)
                if isEpisodeSaved(id: episode.id) {
                    episode.isFavorite = true
                }
                episodes.append(episode)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // Save episode
    func saveEpisode(_ episode: RMEpisode) {
        let cdEpisode = CDEpisode(context: context)
        cdEpisode.id = Int64(episode.id)
        cdEpisode.name = episode.name
        cdEpisode.air_date = episode.air_date
        cdEpisode.url = episode.url
        cdEpisode.created = episode.created
        
        do {
            try context.save()
            print("Saved: \(episode.name)")
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // Eliminar un episodio guardado
    func deleteEpisode(_ episode: RMEpisode) {
        let request: NSFetchRequest<CDEpisode> = CDEpisode.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", episode.id)
        
        do {
            if let cdEpisode = try context.fetch(request).first {
                context.delete(cdEpisode)
                try context.save()
                print("Deleted: \(episode.name)")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    private func isEpisodeSaved(id: Int) -> Bool {
        let request: NSFetchRequest<CDEpisode> = CDEpisode.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        request.fetchLimit = 1
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("Error: \(error.localizedDescription)")
            return false
        }
    }
    
    func toggleFavorite(for episode: RMEpisode) {
        if isEpisodeSaved(id: episode.id) {
            // eliminar
            deleteEpisode(episode)
            updateEpisodeInMemory(id: episode.id, isFavorite: false)
        } else {
            // guardar
            saveEpisode(episode)
            updateEpisodeInMemory(id: episode.id, isFavorite: true)
        }
    }

    /// Actualiza el episodio en el array @Published
    private func updateEpisodeInMemory(id: Int, isFavorite: Bool) {
        if let index = episodes.firstIndex(where: { $0.id == id }) {
            episodes[index].isFavorite = isFavorite
        }
    }
}

