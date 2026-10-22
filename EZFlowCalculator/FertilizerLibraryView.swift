import SwiftUI

struct FertilizerLibraryView: View {
    let store: CalculatorStore
    var onSelect: ((FertilizerProfile) -> Void)?
    @State private var editingFertilizer: FertilizerProfile?
    @State private var deletingFertilizer: FertilizerProfile?

    var body: some View {
        List {
            Section {
                Text("Keep the full label rate for each product here. You'll confirm it before calculating each tank charge.")
                    .foregroundStyle(.secondary)
            }
            Section("Your fertilizers") {
                ForEach(store.library.fertilizers) { fertilizer in
                    VStack(alignment: .leading, spacing: 8) {
                        Button { editingFertilizer = fertilizer } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(fertilizer.name).font(.headline).foregroundStyle(.primary)
                                Text(fertilizer.rateDescription).font(.subheadline).foregroundStyle(.secondary)
                                Text(fertilizer.kind.title).font(.footnote).foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.borderless)
                        if let onSelect {
                            Button("Use this fertilizer") { onSelect(fertilizer) }.buttonStyle(.borderless)
                        }
                    }
                    .swipeActions { Button("Delete", role: .destructive) { deletingFertilizer = fertilizer } }
                }
                Button("Add fertilizer", systemImage: "plus") { editingFertilizer = FertilizerProfile(amount: 0) }
            }
            if let error = store.storageError { Section { Text(error).foregroundStyle(.red) } }
        }
        .navigationTitle("Fertilizers")
        .sheet(item: $editingFertilizer) { fertilizer in
            FertilizerEditor(store: store, fertilizer: fertilizer)
        }
        .confirmationDialog("Delete this fertilizer?", isPresented: .init(
            get: { deletingFertilizer != nil }, set: { if !$0 { deletingFertilizer = nil } }
        ), titleVisibility: .visible) {
            if let fertilizer = deletingFertilizer {
                Button("Delete \(fertilizer.name)", role: .destructive) {
                    store.deleteFertilizer(id: fertilizer.id)
                    deletingFertilizer = nil
                }
            }
        } message: {
            Text("Setups using it will need another fertilizer selected. Their equipment and flow configuration will stay saved.")
        }
    }
}
