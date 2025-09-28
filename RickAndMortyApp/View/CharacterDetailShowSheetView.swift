import SwiftUI

struct CharacterDetailShowSheetView: View {
    let character: RMCharacter
    @EnvironmentObject var viewModel: CharactersViewModel
    @StateObject private var episodesViewModel = EpisodeViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // MARK: - Character Image
                characterImage
                
                // MARK: - Character Info
                characterInfo
                
                // MARK: - Episodes List
                if episodesViewModel.episodes.isEmpty {
                    emptyEpisodesMessage
                } else {
                    episodesList
                }
            }
        }
        .onAppear {
            Task {
                await episodesViewModel.fetchEpisodes(for: character)
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Subviews
private extension CharacterDetailShowSheetView {
    
    var characterImage: some View {
        Group {
            if let url = URL(string: character.image) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 200)
                        
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: 200, height: 200)
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .clipShape(.circle)
                            .cornerRadius(16)
                            .padding(.top, 16)
                        
                    case .failure:
                        Image(systemName: "person.crop.square")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .scaledToFit()
                            .foregroundStyle(.secondary)
                            .padding(.top, 24)
                        
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
    }
    
    var characterInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(character.name)
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            infoRow(title: "Gender", value: character.gender)
            infoRow(title: "Species", value: character.species)
            infoRow(title: "Status", value: character.status)
            infoRow(title: "Location", value: character.location.name)
        }
        .padding()
    }
    
    var episodesList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Favorite Episodes")
                .font(.title2.bold())
                .padding(.top)
            
            ForEach(episodesViewModel.episodes, id: \.id) { episode in
                VStack(alignment: .leading, spacing: 6) {
                    episodeRow(for: episode)
                    Divider()
                }
            }
        }
        .padding(.horizontal)
    }
    
    var emptyEpisodesMessage: some View {
        Text("No episodes for this character")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.top)
    }
    
    @ViewBuilder
    func episodeRow(for episode: RMEpisode) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(episode.name)
                    .font(.headline)
                Text(episode.episode)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Air date: \(episode.air_date)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                episodesViewModel.toggleFavorite(for: episode)
            } label: {
                Image(systemName: episode.isFavorite ? "eye" : "eye.slash")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
    }
    
    @ViewBuilder
    func infoRow(title: String, value: String) -> some View {
        HStack {
            Text("\(title):")
                .font(.headline)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
#Preview {
    CharacterDetailShowSheetView(
        character: RMCharacter(
            id: 1,
            name: "Rick Sanchez",
            status: "Alive",
            species: "Human",
            type: "",
            gender: "Male",
            origin: Origin(name: "Earth", url: ""),
            location: Origin(name: "Earth", url: ""),
            image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
            episode: [],
            url: "",
            created: "",
            isFavorite: false
        )
    )
    .environmentObject(CharactersViewModel())
}
