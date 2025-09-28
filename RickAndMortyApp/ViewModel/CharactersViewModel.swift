import Foundation
import Combine
import CoreData
import SwiftUI
import MapKit
import LocalAuthentication

// Solo representa el estado de la red (no errores ni vacío)
enum NetworkState {
    case idle
    case loading
    case loaded
}

// Estado publicado y único para la UI
struct ViewStatus {
    var network: NetworkState = .idle
    var isEmpty: Bool = false
    var error: String? = nil
}

@MainActor
class CharactersViewModel: ObservableObject {
    // MARK: - Published UI
    @Published var characters: [RMCharacter] = []
    @Published var episodesList: [RMEpisode] = []
    @Published var status: ViewStatus = .init()
    @Published var showAlert = false
    @Published var showCharacterSheet: Bool = false
    
    // MARK: - Security
    @Published var isAuthenticated: Bool = false

    // Búsqueda y filtros
    @Published var textSearch: String = ""
    @Published var filterName: String = ""
    @Published var filterSpecies: String = ""
    @Published var filterStatus: FiltersSheetView.CharacterStatus? = nil
    @Published var shouldApplyFilters: Bool = false
    
    // MapKit
    @Published var characterLocation: CLLocationCoordinate2D? = nil
    @Published var showMap: Bool = false

    // MARK: - Paginación
    private var currentPage = 1
    private var canLoadMore = true

    // MARK: - Persistencia / favoritos
    private let context = PersistenceController.shared.container.viewContext
    private var favoriteCharacters: [CDCharacter] { fetchFavoriteCharacters() }

    // MARK: - Networking
    private var fetchTask: Task<Void, Never>?
    private let baseURL = "https://rickandmortyapi.com/api"
    @Published var characterImages: [Int: UIImage] = [:]

    // MARK: - Lifecycle API
    func startInitialLoad() {
        fetchTask?.cancel()
        fetchTask = Task { [weak self] in
            await self?.fetchAllCharacters()
        }
    }

    func refresh() async {
        fetchTask?.cancel()
        _ = await fetchTask?.value
        resetPagination()
        await fetchAllCharacters()
        showAlert = true
    }

    // MARK: - Private helpers (Estado)
    private func setLoading() {
        status.network = .loading
        status.error = nil
        status.isEmpty = false
    }

    private func setLoaded(isEmpty: Bool) {
        status.network = .loaded
        status.isEmpty = isEmpty
        status.error = nil
    }

    private func setError(_ message: String) {
        status.network = .loaded
        status.error = message
        status.isEmpty = characters.isEmpty
    }

    private func resetPagination() {
        characters = []
        characterImages = [:]
        currentPage = 1
        canLoadMore = true
    }

    private func makeURL(queryItems: [URLQueryItem]) -> URL? {
        var comps = URLComponents(string: "\(baseURL)/character")
        comps?.queryItems = queryItems
        return comps?.url
    }

    private func mergeFavorites(_ items: [RMCharacter]) -> [RMCharacter] {
        let favoriteIds = Set(favoriteCharacters.map { Int($0.id) })
        return items.map { character in
            var updated = character
            updated.isFavorite = favoriteIds.contains(character.id)
            return updated
        }
    }

    private func handleHTTPStatus(_ response: URLResponse, data: Data) throws -> ResponseCharacterModel? {
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        switch http.statusCode {
        case 200:
            return try JSONDecoder().decode(ResponseCharacterModel.self, from: data)
        case 404:
            return nil
        default:
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - Carga completa (paginada)
    private func fetchAllCharacters() async {
        setLoading()
        resetPagination()

        do {
            while canLoadMore {
                if Task.isCancelled { return }

                let items = [URLQueryItem(name: "page", value: "\(currentPage)")]
                guard let url = makeURL(queryItems: items) else { break }

                let (data, response) = try await URLSession.shared.data(from: url)
                if Task.isCancelled { return }

                guard let decoded = try handleHTTPStatus(response, data: data) else {
                    // 404 no aplica en “todas”, solo significaría fin de lista
                    canLoadMore = false
                    break
                }

                let synced = mergeFavorites(decoded.results)
                characters.append(contentsOf: synced)

                // Preload (opcional)
                for c in decoded.results {
                    if Task.isCancelled { return }
                    await preloadImage(for: c)
                }

                if decoded.info.next == nil {
                    canLoadMore = false
                } else {
                    currentPage += 1
                }
            }

            setLoaded(isEmpty: characters.isEmpty)
        } catch {
            if Task.isCancelled { return }
            setError("Error cargando personajes: \(error.localizedDescription)")
        }
    }

    // MARK: - Búsqueda por nombre (primera página)
    func fetchCharactersByName() async {
        setLoading()
        characters = []

        do {
            let items = [URLQueryItem(name: "name", value: textSearch)]
            guard let url = makeURL(queryItems: items) else { return }

            let (data, response) = try await URLSession.shared.data(from: url)
            if Task.isCancelled { return }

            if let decoded = try handleHTTPStatus(response, data: data) {
                let synced = mergeFavorites(decoded.results)
                characters = synced

                for c in decoded.results { await preloadImage(for: c) }
                setLoaded(isEmpty: characters.isEmpty)
            } else {
                characters = []
                setLoaded(isEmpty: true)
            }
        } catch {
            if Task.isCancelled { return }
            setError("Error buscando por nombre: \(error.localizedDescription)")
        }
    }

    // MARK: - Filtros combinados (primera página)
    func fetchCharactersByFilters() async {
        setLoading()
        characters = []

        do {
            var items: [URLQueryItem] = []
            if !filterName.isEmpty     { items.append(.init(name: "name", value: filterName)) }
            if !filterSpecies.isEmpty  { items.append(.init(name: "species", value: filterSpecies)) }
            if let status = filterStatus {
                items.append(.init(name: "status", value: status.rawValue.lowercased()))
            }

            guard let url = makeURL(queryItems: items) else { return }

            let (data, response) = try await URLSession.shared.data(from: url)
            if Task.isCancelled { return }

            if let decoded = try handleHTTPStatus(response, data: data) {
                let synced = mergeFavorites(decoded.results)
                characters = synced

                for c in decoded.results { await preloadImage(for: c) }
                setLoaded(isEmpty: characters.isEmpty)
            } else {
                // 404 => vacío
                characters = []
                setLoaded(isEmpty: true)
            }
        } catch {
            if Task.isCancelled { return }
            setError("Error buscando por filtros: \(error.localizedDescription)")
        }

        shouldApplyFilters = false
    }

    // MARK: - Imágenes
    func preloadImage(for character: RMCharacter) async {
        guard let url = URL(string: character.image) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if Task.isCancelled { return }
            if let image = UIImage(data: data) {
                characterImages[character.id] = image
            }
        } catch {
            if Task.isCancelled { return }
            // Silencioso: no debe tumbar la carga principal
            print("Error loading image:", error)
        }
    }

    // MARK: - Favoritos (Core Data)
    func isFavoriteCharacterSave(_ character: RMCharacter) {
        if character.isFavorite {
            saveFavoriteCharacter(character)
        } else {
            deleteFavoriteCharacter(id: character.id)
        }
    }

    func saveFavoriteCharacter(_ character: RMCharacter) {
        let entity = CDCharacter(context: context)
        entity.id = Int64(character.id)
        entity.name = character.name
        entity.status = character.status
        entity.isFavorite = character.isFavorite
        entity.image = character.image

        do {
            try context.save()
            print("Save character: \(character.name)")
        } catch {
            print("CoreData save error:", error.localizedDescription)
        }
    }

    func deleteFavoriteCharacter(id: Int) {
        let request: NSFetchRequest<CDCharacter> = CDCharacter.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", Int64(id))

        do {
            let results = try context.fetch(request)
            for obj in results { context.delete(obj) }
            if context.hasChanges { try context.save() }
            print("Character(s) with id \(id) deleted")
        } catch {
            print("CoreData delete error:", error)
        }
    }

    func fetchFavoriteCharacters() -> [CDCharacter] {
        let request: NSFetchRequest<CDCharacter> = CDCharacter.fetchRequest()
        do {
            let favorites = try context.fetch(request)
            favorites.forEach { print("➡️ id: \($0.id), name: \($0.name ?? "nil")") }
            return favorites
        } catch {
            print("CoreData fetch error:", error)
            return []
        }
    }
    
    func fetchSimulatedLocation() {
           // Latitudes van de -90 a 90, longitudes de -180 a 180
           let randomLat = Double.random(in: -90...90)
           let randomLon = Double.random(in: -180...180)
           
           characterLocation = CLLocationCoordinate2D(latitude: randomLat, longitude: randomLon)
           showMap = true
       }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Accede a tus favoritos con Face ID"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                }
            }
        }
    }

}

enum ActiveSheet: Identifiable {
    case detail(RMCharacter)
    case map(RMCharacter, CLLocationCoordinate2D)

    var id: String {
        switch self {
        case .detail(let character):
            return "detail_\(character.id)"
        case .map(let character, _):
            return "map_\(character.id)"
        }
    }
}
