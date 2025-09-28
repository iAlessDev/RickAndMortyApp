//
//  CharactersMainView.swift
//  RickAndMortyApp
//
//  Created by Paul Flores on 26/09/25.
//

import SwiftUI

struct CharactersView: View {
    @EnvironmentObject var viewModel: CharactersViewModel
    @State private var selectedCharacter: RMCharacter? = nil
    @State private var showFiltersSheet = false
    @State private var activeSheet: ActiveSheet? = nil

    var body: some View {
        NavigationView {
            content
                .task { viewModel.startInitialLoad() }
                .navigationTitle("Characters")
                .navigationBarTitleDisplayMode(.large)
                .alert(isPresented: $viewModel.showAlert) {
                    Alert(
                        title: Text("Success"),
                        message: Text("All characters have been loaded")
                    )
                }
                .searchable(text: $viewModel.textSearch)
                .onChange(of: viewModel.textSearch) { _, newValue in
                    Task {
                        if !newValue.isEmpty {
                            await viewModel.fetchCharactersByName()
                        }
                    }
                }
                .sheet(isPresented: $showFiltersSheet) {
                    FiltersSheetView(
                        name: $viewModel.filterName,
                        species: $viewModel.filterSpecies,
                        status: $viewModel.filterStatus
                    )
                    .environmentObject(viewModel)
                }
                .toolbar {
                    Button {
                        showFiltersSheet = true
                    } label: {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
                .onChange(of: viewModel.shouldApplyFilters) { _, newValue in
                    if newValue {
                        Task { await viewModel.fetchCharactersByFilters() }
                    }
                }
        }
    }
}

// MARK: - Main Content
private extension CharactersView {
    @ViewBuilder
    var content: some View {
        if viewModel.status.network == .loading && viewModel.characters.isEmpty {
            loadingView
        } else if let error = viewModel.status.error, viewModel.characters.isEmpty {
            errorView(error: error)
        } else if viewModel.status.isEmpty && viewModel.characters.isEmpty {
            emptyView
        } else {
            listView
                .refreshable {
                    await viewModel.refresh()
                }
        }
    }
    
    var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
            Spacer()
        }
    }
    
    func errorView(error: String) -> some View {
        VStack {
            Image(systemName: "x.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(.red)
            Text("An error occurred")
                .font(.headline)
            Text(error)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    var emptyView: some View {
        VStack {
            Image(systemName: "person.crop.circle.badge.exclam")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(.secondary)
            Text("No characters found")
                .font(.headline)
        }
    }
    
    var listView: some View {
        List {
            ForEach(Array(viewModel.characters.enumerated()), id: \.element.id) { index, character in
                CharacterRow(
                    character: character,
                    image: viewModel.characterImages[character.id],
                    onFavoriteToggle: {
                        viewModel.characters[index].isFavorite.toggle()
                        viewModel.isFavoriteCharacterSave(viewModel.characters[index])
                    },
                    onMapTap: {
                        viewModel.fetchSimulatedLocation()
                        if let coordinate = viewModel.characterLocation {
                            activeSheet = .map(character, coordinate)
                        }
                    },
                    onDetailTap: {
                        activeSheet = .detail(character)
                    }
                )
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .detail(let character):
                CharacterDetailShowSheetView(character: character)
                    .environmentObject(viewModel)
            case .map(let character, let coordinate):
                CharacterMapView(coordinate: coordinate, name: character.name)
            }
        }
    }
}

// MARK: - Character Row
private struct CharacterRow: View {
    let character: RMCharacter
    let image: UIImage?
    let onFavoriteToggle: () -> Void
    let onMapTap: () -> Void
    let onDetailTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            characterImage
            
            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.headline)
                Text("\(character.species) - \(character.status)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Favorite button
            Button(action: onFavoriteToggle) {
                Image(systemName: character.isFavorite ? "star.fill" : "star")
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color(.systemBlue))
            }
            .accessibilityIdentifier("favoriteButton_\(character.id)")
            .buttonStyle(.borderless)
            
            // Map button
            Button(action: onMapTap) {
                Image(systemName: "map")
                    .foregroundStyle(Color(.systemBlue))
            }
            .accessibilityIdentifier("mapButton")
            .buttonStyle(.borderless)
            
            // Detail button
            Button(action: onDetailTap) {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(Color(.systemBlue))
            }
            .accessibilityIdentifier("detailButton")
            .buttonStyle(.borderless)
        }
    }
    
    private var characterImage: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Color.clear.frame(width: 100, height: 100)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    CharactersView()
        .environmentObject(CharactersViewModel())
}
