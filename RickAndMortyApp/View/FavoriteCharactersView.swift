//
//  FavoriteCharactersView.swift
//  RickAndMortyApp
//
//  Created by Paul Flores on 27/09/25.
//

import SwiftUI
import CoreData

@MainActor
struct FavoriteCharactersView: View {
    @StateObject private var viewModel = FavoriteCharacterViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.characters.isEmpty {
                    emptyState
                } else {
                    listView
                }
            }
            .onAppear { viewModel.fetchFavoriteCharacters() }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Subviews
private extension FavoriteCharactersView {
    
    var emptyState: some View {
        Text("No favorite characters yet")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
    
    var listView: some View {
        List {
            ForEach(viewModel.characters, id: \.objectID) { character in
                FavoriteCharacterRow(
                    character: character,
                    onDelete: {
                        viewModel.deleteFavoriteCharacter(id: Int(character.id))
                    }
                )
            }
        }
    }
}

// MARK: - Character Row
private struct FavoriteCharacterRow: View {
    let character: CDCharacter
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            characterImage
            
            VStack(alignment: .leading, spacing: 4) {
                Text(character.name ?? "Unknown")
                    .font(.headline)
                Text(character.status ?? "Unknown")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: character.isFavorite ? "star.fill" : "star")
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color(.systemBlue))
            }
            .buttonStyle(.borderless)
        }
    }
    
    private var characterImage: some View {
        Group {
            if let urlString = character.image, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 100, height: 100)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .failure:
                        placeholderImage
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                placeholderImage
            }
        }
    }
    
    private var placeholderImage: some View {
        Image(systemName: "person.crop.square")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .foregroundStyle(.secondary)
    }
}

// MARK: - Preview
#Preview {
    FavoriteCharactersView()
}
