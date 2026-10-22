import SwiftUI

struct RateConfirmationView: View {
    @Environment(\.dismiss) private var dismiss
    let store: CalculatorStore
    let setup: IrrigationSetup
    @State private var fertilizer: FertilizerProfile
    @State private var showingResult = false

    init(store: CalculatorStore, setup: IrrigationSetup, fertilizer: FertilizerProfile) {
        self.store = store
        self.setup = setup
        _fertilizer = State(initialValue: fertilizer)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Is this still the rate you want to use?").font(.headline)
                    Text("Check your product label. Any rate you confirm here is automatically saved to this fertilizer for every setup.")
                        .foregroundStyle(.secondary)
                }
                FertilizerFields(fertilizer: $fertilizer)
                Section("This feeding") {
                    LabeledContent("Setup", value: setup.name)
                    LabeledContent("Label rate", value: fertilizer.rateDescription)
                    LabeledContent("Rate used", value: "\((fertilizer.amount * (setup.firstFeedingOfSeason ? 0.5 : 1)).formatted()) \(fertilizer.unit.displayName) \(fertilizer.basis.displayName)")
                    if setup.firstFeedingOfSeason {
                        Label("First feeding of the season: 50% of the full label rate.", systemImage: "leaf")
                    }
                    Button("Confirm rate & calculate", systemImage: "checkmark.circle", action: confirm)
                        .font(.headline).disabled(!fertilizer.isValid || !setup.hasValidFlow)
                        .accessibilityIdentifier("confirmRate")
                }
                if let error = store.storageError { Section { Text(error).foregroundStyle(.red) } }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Confirm label rate").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                KeyboardDoneToolbar()
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
            .navigationDestination(isPresented: $showingResult) {
                FeedingResultView(setup: setup, fertilizer: fertilizer)
                    .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
            }
        }
    }

    private func confirm() {
        guard fertilizer.isValid, setup.hasValidFlow, store.saveFertilizer(fertilizer) else { return }
        showingResult = true
    }
}
