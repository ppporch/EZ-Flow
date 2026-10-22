import SwiftUI

struct SetupDetailView: View {
    let store: CalculatorStore
    @State private var setup: IrrigationSetup
    @State private var showingRate = false
    @State private var showingFertilizers = false
    @State private var showingSchedule = false
    @State private var editingComponent: DripComponent?
    @State private var discToInstall: FlowDisc?
    @State private var confirmingDisc = false
    @FocusState private var focusedField: FocusedField?

    init(store: CalculatorStore, setup: IrrigationSetup) {
        self.store = store
        _setup = State(initialValue: setup)
    }

    private var fertilizer: FertilizerProfile? { store.fertilizer(id: setup.fertilizerID) }

    var body: some View {
        Form {
            Section {
                TextField("Setup name", text: $setup.name).accessibilityLabel("Setup name")
                Text("Changes to this setup are saved automatically.").font(.footnote).foregroundStyle(.secondary)
            }
            Section("1. Installed equipment") {
                Picker("Tank size", selection: $setup.tankSize) {
                    ForEach(TankSize.allCases) { size in Text(size.displayName).tag(size) }
                }
                Picker("Feed setting on cap", selection: $setup.feedSetting) {
                    ForEach(FeedSetting.allCases) { setting in Text(setting.displayName).tag(setting) }
                }
                Text("Use the setting and disc actually installed. If you change either on the equipment, update this setup before measuring a new charge.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            FlowConfigurationSection(setup: $setup, onEdit: { editingComponent = $0 })
            DiscGuidanceSection(flowGPH: setup.flowGPH, installedDisc: $setup.disc, onConfirmInstallation: {
                discToInstall = $0
                confirmingDisc = true
            })
            Section("3. Fertilizer") {
                Picker("Saved fertilizer", selection: $setup.fertilizerID) {
                    Text("Choose a fertilizer").tag(nil as UUID?)
                    ForEach(store.library.fertilizers) { profile in Text(profile.name).tag(Optional(profile.id)) }
                }
                if let fertilizer { LabeledContent("Saved label rate", value: fertilizer.rateDescription) }
                Button("Add or edit fertilizers", systemImage: "plus.circle") { showingFertilizers = true }
                Toggle("First feeding of the season", isOn: $setup.firstFeedingOfSeason)
                Text(setup.firstFeedingOfSeason
                     ? "Uses 50% of the full label rate. This switch is remembered for this setup; turn it off for later feedings."
                     : "Turn on to use 50% of the full label rate for the first feeding of the season.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section {
                Button("Review rate & calculate", systemImage: "checkmark.circle", action: reviewRate)
                    .font(.headline).disabled(!setup.hasValidFlow || fertilizer == nil).accessibilityIdentifier("reviewRate")
                if !setup.hasValidFlow {
                    Text("Enter a positive total flow or add valid dripper and line groups to continue.").foregroundStyle(.orange)
                } else if fertilizer == nil {
                    Text("Add and choose a fertilizer to continue.").foregroundStyle(.secondary)
                }
            }
            Section {
                DisclosureGroup("Optional watering schedule", isExpanded: $showingSchedule) {
                    WateringScheduleSection(wateringIntervalDays: $setup.wateringIntervalDays,
                                           minutesPerSession: $setup.minutesPerSession, focusedField: $focusedField)
                }
            }
            if let error = store.storageError { Section { Text(error).foregroundStyle(.red) } }
        }
        .navigationTitle(setup.name.isEmpty ? "Drip setup" : setup.name).navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .toolbar { KeyboardDoneToolbar() }
        .onChange(of: setup) { store.saveSetup(setup) }
        .onChange(of: store.library.fertilizers) {
            if let id = setup.fertilizerID, store.fertilizer(id: id) == nil { setup.fertilizerID = nil }
        }
        .sheet(isPresented: $showingFertilizers) {
            NavigationStack {
                FertilizerLibraryView(store: store, onSelect: { profile in
                    setup.fertilizerID = profile.id
                    showingFertilizers = false
                })
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showingFertilizers = false } } }
            }
        }
        .sheet(isPresented: $showingRate) {
            if let fertilizer { RateConfirmationView(store: store, setup: setup, fertilizer: fertilizer) }
        }
        .sheet(item: $editingComponent) { component in
            DripComponentEditor(component: component, onSave: saveComponent)
        }
        .confirmationDialog("Does this match your installed equipment?", isPresented: $confirmingDisc, titleVisibility: .visible) {
            if let discToInstall { Button("Use \(discToInstall.displayName)") { setup.disc = discToInstall } }
        } message: {
            Text("Only update the selection after changing the equipment. Recalculate before filling the tank.")
        }
    }

    private func reviewRate() { focusedField = nil; showingRate = true }

    private func saveComponent(_ component: DripComponent) {
        if let index = setup.components.firstIndex(where: { $0.id == component.id }) {
            setup.components[index] = component
        } else {
            setup.components.append(component)
        }
    }
}
