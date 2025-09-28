//
//  RickAndMortyApp
//
//  Created by Paul Flores on 28/09/25.
//

import SwiftUI
import CoreData

struct SheetMapCharactersView: View {
    let character: RMCharacter
    @EnvironmentObject var detailVM: CharactersViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Info del personaje
                Text(character.name)
                    .font(.title)
                
                // Botón para abrir el mapa
                Button("Ver en mapa") {
                    detailVM.fetchSimulatedLocation()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}


#Preview {
    SheetMapCharactersView(
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

