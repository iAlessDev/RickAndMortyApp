//
//  CharacterMapView.swift
//  RickAndMortyApp
//
//  Created by Paul Flores on 28/09/25.
//

import SwiftUI
import MapKit

struct CharacterMapView: View {
    let coordinate: CLLocationCoordinate2D
    let name: String
    
    @State private var position: MapCameraPosition
    
    init(coordinate: CLLocationCoordinate2D, name: String) {
        self.coordinate = coordinate
        self.name = name
        _position = State(initialValue: .region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )))
    }
    
    var body: some View {
        Map(position: $position) {
            Marker(name, coordinate: coordinate)
                .tint(.red)
        }
        .ignoresSafeArea()
        .overlay(
            Text("Last location of \(name)")
                .font(.headline)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(8)
                .padding(),
            alignment: .top
        )
    }
}

#Preview {
    CharacterMapView(coordinate: CLLocationCoordinate2D(latitude: -50, longitude: 20), name: "Rick")
}
