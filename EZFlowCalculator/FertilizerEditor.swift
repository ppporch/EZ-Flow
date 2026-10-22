import SwiftUI

struct FertilizerEditor: View {
    @Environment(\.dismiss) private var dismiss
    let store: CalculatorStore
    @State private var fertilizer: FertilizerProfile
    let onSave: ((FertilizerProfile) -> Void)?

    init(store: CalculatorStore, fertilizer: FertilizerProfile, onSave: ((FertilizerProfile) -> Void)? = nil) {
        self.store = store
        _fertilizer = State(initialValue: fertilizer)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                FertilizerFields(fertilizer: $fertilizer)
                Section {
                    Text("This profile is shared by all setups. Saving a changed label rate updates it everywhere.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                if let error = store.storageError { Section { Text(error).foregroundStyle(.red) } }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Save fertilizer").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                KeyboardDoneToolbar()
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save", action: save).disabled(!fertilizer.isValid) }
            }
        }
    }

    private func save() {
        guard store.saveFertilizer(fertilizer) else { return }
        dismiss()
        onSave?(fertilizer)
    }
}
