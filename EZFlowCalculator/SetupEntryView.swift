import SwiftUI

struct SetupEntryView: View {
    let store: CalculatorStore
    let setupID: UUID
    @State private var startsInEditor: Bool

    init(store: CalculatorStore, setup: IrrigationSetup) {
        self.store = store
        setupID = setup.id
        // Keep an incomplete setup in the editor while its fields are being filled.
        _startsInEditor = State(initialValue: !setup.canCalculate(with: store.fertilizer(id: setup.fertilizerID)))
    }

    var body: some View {
        Group {
            if let setup = store.setup(id: setupID) {
                if startsInEditor {
                    SetupDetailView(store: store, setup: setup)
                } else {
                    SetupSummaryView(store: store, setupID: setupID)
                }
            } else {
                ContentUnavailableView("Location unavailable", systemImage: "leaf")
            }
        }
    }
}
