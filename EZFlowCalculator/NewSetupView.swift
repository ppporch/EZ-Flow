import SwiftUI

struct NewSetupView: View {
    @Environment(\.dismiss) private var dismiss
    let store: CalculatorStore
    let onSave: (UUID) -> Void
    @State private var setup = IrrigationSetup(directFlowGPH: 0)

    var body: some View {
        NavigationStack {
            Form {
                Section("Name your installed system") {
                    TextField("For example, Vegetable garden", text: $setup.name).accessibilityIdentifier("setupName")
                    Picker("Tank size", selection: $setup.tankSize) {
                        ForEach(TankSize.allCases) { size in Text(size.displayName).tag(size) }
                    }
                }
                Section {
                    Text("Next, enter your flow, installed Flo-Disc, and feed setting. You can save a different setup for each injector.")
                        .foregroundStyle(.secondary)
                }
                if let error = store.storageError { Section { Text(error).foregroundStyle(.red) } }
            }
            .navigationTitle("New setup").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                KeyboardDoneToolbar()
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create", action: create).disabled(setup.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func create() {
        guard store.saveSetup(setup) else { return }
        dismiss()
        onSave(setup.id)
    }
}
