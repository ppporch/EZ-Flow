import SwiftUI

struct ContentView: View {
    @State private var store = CalculatorStore()
    @State private var path: [UUID] = []
    @State private var didOpenInitialSetup = false
    @State private var showingNewSetup = false
    @State private var deletingSetup: IrrigationSetup?

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    Label("How much fertilizer should I add?", systemImage: "leaf").font(.headline)
                    Text("Choose your location, review its saved settings, and see how much fertilizer to add.")
                        .foregroundStyle(.secondary)
                }
                Section("Your locations") {
                    ForEach(store.library.setups) { setup in
                        NavigationLink(value: setup.id) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(setup.name).font(.headline)
                                Text("\(setup.tankSize.displayName) · \(setup.flowGPH.formatted(.number.precision(.fractionLength(0...1)))) GPH")
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        .swipeActions { Button("Delete", role: .destructive) { deletingSetup = setup } }
                    }
                    Button("Add setup", systemImage: "plus") { showingNewSetup = true }
                        .accessibilityIdentifier("addSetup")
                }
                Section {
                    NavigationLink { FertilizerLibraryView(store: store) } label: {
                        Label("Saved fertilizers", systemImage: "books.vertical")
                    }
                } footer: {
                    Text("Fertilizer profiles are shared across all setups. Everything is saved on this device.")
                }
                if let error = store.storageError {
                    Section { Label(error, systemImage: "exclamationmark.triangle").foregroundStyle(.red) }
                }
            }
            .navigationTitle("EZ-Flow")
            .navigationDestination(for: UUID.self) { id in
                if let setup = store.setup(id: id) {
                    SetupEntryView(store: store, setup: setup)
                } else {
                    ContentUnavailableView("Setup unavailable", systemImage: "leaf")
                }
            }
            .sheet(isPresented: $showingNewSetup) {
                NewSetupView(store: store) { id in path.append(id) }
            }
            .confirmationDialog("Delete this setup?", isPresented: .init(
                get: { deletingSetup != nil }, set: { if !$0 { deletingSetup = nil } }
            ), titleVisibility: .visible) {
                if let setup = deletingSetup {
                    Button("Delete \(setup.name)", role: .destructive) {
                        store.deleteSetup(id: setup.id)
                        deletingSetup = nil
                    }
                }
            } message: {
                Text("Its saved equipment and drip configuration will be removed. Shared fertilizers will stay available.")
            }
            .onAppear {
                guard !didOpenInitialSetup else { return }
                didOpenInitialSetup = true
                if store.library.setups.count == 1, let setup = store.library.setups.first { path = [setup.id] }
            }
        }
    }
}

#Preview { ContentView() }
