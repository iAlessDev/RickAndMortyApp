import SwiftUI

struct FiltersSheetView: View {
    @Environment(\.dismiss) private var dismiss

    // Bindings provided by the presenting view
    @Binding var name: String
    @Binding var species: String
    @Binding var status: CharacterStatus?
    
    @EnvironmentObject var viewModel: CharactersViewModel

    enum CharacterStatus: String, CaseIterable, Identifiable {
        case alive = "Alive"
        case dead = "Dead"
        case unknown = "unknown"

        var id: String { rawValue }
    }

    init(name: Binding<String>, species: Binding<String>, status: Binding<CharacterStatus?>) {
        self._name = name
        self._species = species
        self._status = status
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Name contains…", text: $name)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                }

                Section("Species") {
                    TextField("Species contains…", text: $species)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                }

                Section("Status") {
                    Picker("Status", selection: Binding<CharacterStatus?>(
                        get: { status },
                        set: { status = $0 }
                    )) {
                        Text("Any").tag(CharacterStatus?.none)
                        ForEach(CharacterStatus.allCases) { s in
                            Text(s.rawValue).tag(CharacterStatus?.some(s))
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        // The presenting view reads the bound values
                        dismiss()
                        viewModel.shouldApplyFilters = true
                    }
                    .disabled(name.isEmpty && species.isEmpty && status == nil)
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Clear Filters") {
                        name = ""
                        species = ""
                        status = nil
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var name: String = ""
    @Previewable @State var species: String = ""
    @Previewable @State var status: FiltersSheetView.CharacterStatus? = nil

    return FiltersSheetView(name: $name, species: $species, status: $status)
        .environmentObject(CharactersViewModel())
}
