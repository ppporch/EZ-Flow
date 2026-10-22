import SwiftUI

struct SetupSummaryView: View {
    let store: CalculatorStore
    let setupID: UUID
    @State private var showingEditor = false
    @State private var acceptedFeeding: ConfirmedFeeding?

    var body: some View {
        Group {
            if let setup = store.setup(id: setupID) {
                let fertilizer = store.fertilizer(id: setup.fertilizerID)
                Form {
                    Section("Saved settings") {
                        LabeledContent("Fertilizer", value: fertilizer?.name ?? "Choose a fertilizer")
                        LabeledContent("Full label rate", value: fertilizer?.rateDescription ?? "Not set")
                        LabeledContent("First feeding of the season", value: setup.firstFeedingOfSeason ? "On · 50% rate" : "Off · full rate")
                        LabeledContent("Tank size", value: setup.tankSize.displayName)
                        LabeledContent("Installed Flo-Disc", value: setup.disc.displayName)
                        LabeledContent("Feed setting", value: setup.feedSetting.displayName)
                        LabeledContent("Total flow", value: "\(setup.flowGPH.formatted(.number.precision(.fractionLength(0...2)))) GPH")
                    }
                    Section {
                        Button("Use these settings", systemImage: "checkmark.circle.fill", action: accept)
                            .font(.headline)
                            .disabled(!setup.canCalculate(with: fertilizer))
                            .accessibilityIdentifier("useSavedSettings")
                        Button("Change settings", systemImage: "slider.horizontal.3") { showingEditor = true }
                            .accessibilityIdentifier("changeSavedSettings")
                    } footer: {
                        Text("Using these settings confirms the saved label rate and shows the amount to add.")
                    }
                    if !setup.canCalculate(with: fertilizer) {
                        Section {
                            Label("Complete the flow and fertilizer information in Change settings to continue.", systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.orange)
                        }
                    } else if !setup.disc.isFlowInRange(setup.flowGPH) {
                        Section {
                            Label(setup.disc.flowMessage(for: setup.flowGPH), systemImage: "exclamationmark.triangle")
                                .font(.footnote).foregroundStyle(.orange)
                        }
                    }
                }
                .navigationTitle(setup.name).navigationBarTitleDisplayMode(.inline)
                .navigationDestination(isPresented: $showingEditor) {
                    SetupDetailView(store: store, setup: setup)
                }
            } else {
                ContentUnavailableView("Location unavailable", systemImage: "leaf")
            }
        }
        .sheet(item: $acceptedFeeding) { feeding in
            NavigationStack {
                FeedingResultView(setup: feeding.setup, fertilizer: feeding.fertilizer)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { acceptedFeeding = nil }
                        }
                    }
            }
        }
    }

    private func accept() {
        acceptedFeeding = store.confirmSavedSetup(id: setupID)
    }
}
