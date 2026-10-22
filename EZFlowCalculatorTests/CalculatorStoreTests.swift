import Foundation
import Testing
@testable import EZFlowCalculator

struct CalculatorStoreTests {
    @Test @MainActor func quickReviewUsesLatestSharedRateAndKeepsAcceptedResultStable() throws {
        let domain = "EZFlowTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: domain))
        defer { defaults.removePersistentDomain(forName: domain) }
        let store = CalculatorStore(defaults: defaults)
        var fertilizer = FertilizerProfile(name: "Shared food")
        store.saveFertilizer(fertilizer)
        let setup = IrrigationSetup(name: "Garden", fertilizerID: fertilizer.id, firstFeedingOfSeason: true)
        store.saveSetup(setup)
        let accepted = try #require(store.confirmSavedSetup(id: setup.id))
        #expect(accepted.setup.calculation(for: accepted.fertilizer).productTeaspoons == 31.25)
        fertilizer.amount = 4
        store.saveFertilizer(fertilizer)
        let next = try #require(store.confirmSavedSetup(id: setup.id))
        #expect(next.fertilizer.amount == 4)
        #expect(next.setup.calculation(for: next.fertilizer).productTeaspoons == 62.5)
        #expect(accepted.fertilizer.amount == 2)
        #expect(store.setup(id: setup.id)?.firstFeedingOfSeason == true)
        #expect(store.library.fertilizers.count == 1)
    }

    @Test @MainActor func quickReviewCannotAcceptIncompleteOrDeletedLocations() throws {
        let domain = "EZFlowTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: domain))
        defer { defaults.removePersistentDomain(forName: domain) }
        let store = CalculatorStore(defaults: defaults)
        let fertilizer = FertilizerProfile(name: "Food")
        store.saveFertilizer(fertilizer)
        var setup = IrrigationSetup(name: "Garden", directFlowGPH: 0, fertilizerID: fertilizer.id)
        store.saveSetup(setup)
        #expect(store.confirmSavedSetup(id: setup.id) == nil)
        setup.directFlowGPH = 104
        store.saveSetup(setup)
        #expect(store.confirmSavedSetup(id: setup.id) != nil)
        store.deleteFertilizer(id: fertilizer.id)
        #expect(store.confirmSavedSetup(id: setup.id) == nil)
        store.deleteSetup(id: setup.id)
        #expect(store.confirmSavedSetup(id: setup.id) == nil)
    }

    @Test func quickReviewRequiresTheSelectedValidFertilizer() {
        var fertilizer = FertilizerProfile(name: "Food")
        let setup = IrrigationSetup(name: "Garden", fertilizerID: fertilizer.id)
        #expect(setup.canCalculate(with: fertilizer))
        #expect(setup.canCalculate(with: FertilizerProfile(name: "Different food")) == false)
        fertilizer.amount = 0
        #expect(setup.canCalculate(with: fertilizer) == false)
        #expect(setup.canCalculate(with: nil) == false)
    }

    @Test @MainActor func setupsAndSharedProductsSurviveRelaunch() throws {
        let domain = "EZFlowTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: domain))
        defer { defaults.removePersistentDomain(forName: domain) }
        let store = CalculatorStore(defaults: defaults)
        let fertilizer = FertilizerProfile(name: "Tomato food")
        #expect(store.saveFertilizer(fertilizer))
        let first = IrrigationSetup(name: "Vegetables", flowMode: .components,
                                    components: [DripComponent(name: "Raised bed", count: 52, emitterGPH: 2)],
                                    fertilizerID: fertilizer.id, firstFeedingOfSeason: true)
        let second = IrrigationSetup(name: "Flowers", tankSize: .threeQuarterGallon, fertilizerID: fertilizer.id)
        #expect(store.saveSetup(first))
        #expect(store.saveSetup(second))
        let reopened = CalculatorStore(defaults: defaults)
        #expect(reopened.library.setups.count == 2)
        #expect(reopened.setup(id: first.id) == first)
        #expect(reopened.setup(id: first.id)?.flowGPH == 104)
        #expect(reopened.setup(id: second.id) == second)
        #expect(reopened.fertilizer(id: fertilizer.id) == fertilizer)
        #expect(reopened.storageError == nil)
    }

    @Test @MainActor func confirmingNewRateUpdatesAllLinkedSetups() throws {
        let domain = "EZFlowTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: domain))
        defer { defaults.removePersistentDomain(forName: domain) }
        let store = CalculatorStore(defaults: defaults)
        var fertilizer = FertilizerProfile(name: "Shared food")
        store.saveFertilizer(fertilizer)
        let first = IrrigationSetup(name: "First", fertilizerID: fertilizer.id)
        let second = IrrigationSetup(name: "Second", fertilizerID: fertilizer.id, firstFeedingOfSeason: true)
        store.saveSetup(first)
        store.saveSetup(second)
        fertilizer.amount = 4
        #expect(store.saveFertilizer(fertilizer))
        let reopened = CalculatorStore(defaults: defaults)
        let updated = try #require(reopened.fertilizer(id: first.fertilizerID))
        #expect(updated.amount == 4)
        #expect(first.calculation(for: updated).productTeaspoons == 125)
        #expect(second.calculation(for: updated).productTeaspoons == 62.5)
        #expect(reopened.library.fertilizers.count == 1)
    }

    @Test @MainActor func deletingProductClearsLinksWithoutDeletingEquipment() throws {
        let domain = "EZFlowTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: domain))
        defer { defaults.removePersistentDomain(forName: domain) }
        let store = CalculatorStore(defaults: defaults)
        let fertilizer = FertilizerProfile(name: "Food")
        store.saveFertilizer(fertilizer)
        let setup = IrrigationSetup(name: "Garden", fertilizerID: fertilizer.id)
        store.saveSetup(setup)
        store.deleteFertilizer(id: fertilizer.id)
        let saved = try #require(store.setup(id: setup.id))
        #expect(saved.fertilizerID == nil)
        #expect(saved.disc == setup.disc)
        #expect(saved.directFlowGPH == 104)
        store.saveFertilizer(fertilizer)
        store.deleteSetup(id: setup.id)
        #expect(store.library.setups.isEmpty)
        #expect(store.library.fertilizers.count == 1)
    }

    @Test @MainActor func corruptLibraryIsPreserved() throws {
        let domain = "EZFlowTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: domain))
        defer { defaults.removePersistentDomain(forName: domain) }
        let corrupt = Data("unreadable".utf8)
        defaults.set(corrupt, forKey: CalculatorStore.storageKey)
        let store = CalculatorStore(defaults: defaults)
        #expect(store.storageError != nil)
        #expect(store.saveSetup(IrrigationSetup(name: "Garden")) == false)
        #expect(defaults.data(forKey: CalculatorStore.storageKey) == corrupt)
    }

    @Test @MainActor func importsCurrentPersonalSettingsOnce() throws {
        let domain = "EZFlowTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: domain))
        defer { defaults.removePersistentDomain(forName: domain) }
        defaults.set(80.0, forKey: "flowRate")
        defaults.set("threeQuarterGallon", forKey: "tankSize")
        defaults.set("black", forKey: "selectedDisc")
        defaults.set("one", forKey: "selectedSetting")
        defaults.set(3.0, forKey: "fertilizerAmount")
        defaults.set("fluidOunce", forKey: "fertilizerUnit")
        let store = CalculatorStore(defaults: defaults)
        let setup = try #require(store.library.setups.first)
        let profile = try #require(store.fertilizer(id: setup.fertilizerID))
        #expect(setup.flowGPH == 80)
        #expect(setup.tankSize == .threeQuarterGallon)
        #expect(setup.disc == .black)
        #expect(setup.feedSetting == .one)
        #expect(profile.amount == 3)
        #expect(profile.kind == .liquid)
        #expect(profile.isValid)
        #expect(CalculatorStore(defaults: defaults).library.setups.count == 1)
    }

    @Test(arguments: [0.0, -1, Double.nan, Double.infinity])
    func invalidLabelRatesCannotBeConfirmed(amount: Double) {
        #expect(FertilizerProfile(name: "Food", amount: amount).isValid == false)
    }

    @Test func powderCannotUseLiquidOuncesAsWeight() {
        #expect(FertilizerProfile(name: "Food", unit: .fluidOunce).isValid == false)
        #expect(FertilizerProfile(name: "Food", kind: .liquid, unit: .fluidOunce).isValid)
    }
}
