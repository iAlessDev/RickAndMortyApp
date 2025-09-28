//
//  MainTabView.swift
//  CuidApp
//
//  Created by Paul Flores on 07/07/25.
//

import SwiftUI

struct MainTabView: View {
    // Estado para la pestaña seleccionada
    @State private var selection: Tab = .characters
    @StateObject var viewModel = CharactersViewModel()
    
    
    // Definimos un enum para las pestañas
    enum Tab {
        case characters, favourites, search, episodes
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                TabView(selection: $selection) {
                    // 1. Home
                    CharactersView()
                        .tag(Tab.characters)
                        .tabItem {
                            Label("", systemImage: selection == .characters ? "house.fill" : "house")
                        }
                        .environmentObject(viewModel)
                    
                    // 2. favourites
                    FavoriteCharactersView()
                        .blur(radius: viewModel.isAuthenticated ? 0 : 20)
                        .overlay {
                            if !viewModel.isAuthenticated {
                                VStack {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 40))
                                        .padding(.bottom, 8)
                                    Text("Favoritos bloqueados")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.ultraThinMaterial) // efecto vidrio
                            }
                        }
                        .tag(Tab.favourites)
                        .tabItem {
                            Label("", systemImage: selection == .favourites ? "star.fill" : "star")
                        }

                }
            }
            .onChange(of: selection) { _, newValue in
                if newValue == .favourites {
                    if !viewModel.isAuthenticated {
                        viewModel.authenticate()
                    }
                }
            }
        }
    }
}

#Preview {
    MainTabView()
}
