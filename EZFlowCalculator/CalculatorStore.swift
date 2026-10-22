import Foundation
import Observation

@MainActor @Observable
final class CalculatorStore {
    private(set) var library = SavedLibrary()
    private(set) var storageError: String?
    private let defaults: UserDefaults
    private var canSave = true
    static let storageKey = "calculatorLibrary.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.storageKey) {
            do {
                let decoded = try JSONDecoder().decode(SavedLibrary.self, from: data)
                guard decoded.version == 1 else { throw CocoaError(.coderReadCorrupt) }
                library = decoded
            } catch {
                // Preserve unreadable data rather than overwriting a user's library.
                canSave = false
                storageError = "Your saved library could not be read. It has been preserved. Close and reopen the app, or restore your device backup."
            }
        } else if defaults.object(forKey: "flowRate") != nil {
            importCurrentSetup()
        }
    }

    func setup(id: UUID) -> IrrigationSetup? { library.setups.first { $0.id == id } }
    func fertilizer(id: UUID?) -> FertilizerProfile? { library.fertilizers.first { $0.id == id } }

    func confirmSavedSetup(id: UUID) -> ConfirmedFeeding? {
        guard let setup = setup(id: id),
              let fertilizer = fertilizer(id: setup.fertilizerID),
              setup.canCalculate(with: fertilizer) else { return nil }
        return ConfirmedFeeding(setup: setup, fertilizer: fertilizer)
    }

    @discardableResult
    func saveSetup(_ setup: IrrigationSetup) -> Bool {
        var next = library
        var trimmed = setup
        trimmed.name = trimmed.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.name.isEmpty { trimmed.name = "My drip system" }
        if let index = next.setups.firstIndex(where: { $0.id == setup.id }) {
            next.setups[index] = trimmed
        } else {
            next.setups.append(trimmed)
        }
        return persist(next)
    }

    @discardableResult
    func saveFertilizer(_ profile: FertilizerProfile) -> Bool {
        guard profile.isValid else { return false }
        var next = library
        var trimmed = profile
        trimmed.name = trimmed.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let index = next.fertilizers.firstIndex(where: { $0.id == profile.id }) {
            next.fertilizers[index] = trimmed
        } else {
            next.fertilizers.append(trimmed)
        }
        return persist(next)
    }

    func deleteSetup(id: UUID) {
        var next = library
        next.setups.removeAll { $0.id == id }
        persist(next)
    }

    func deleteFertilizer(id: UUID) {
        var next = library
        next.fertilizers.removeAll { $0.id == id }
        for index in next.setups.indices where next.setups[index].fertilizerID == id {
            next.setups[index].fertilizerID = nil
        }
        persist(next)
    }

    @discardableResult
    private func persist(_ next: SavedLibrary) -> Bool {
        guard canSave else { return false }
        do {
            let data = try JSONEncoder().encode(next)
            defaults.set(data, forKey: Self.storageKey)
            library = next
            storageError = nil
            return true
        } catch {
            storageError = "The changes could not be saved. Check that all entered numbers are valid."
            return false
        }
    }

    private func importCurrentSetup() {
        var fertilizer = FertilizerProfile(name: "My fertilizer")
        fertilizer.amount = defaults.object(forKey: "fertilizerAmount") as? Double ?? 2
        fertilizer.unit = FertilizerRateUnit(rawValue: defaults.string(forKey: "fertilizerUnit") ?? "") ?? .teaspoon
        if fertilizer.unit == .fluidOunce { fertilizer.kind = .liquid }
        fertilizer.basis = FertilizerRateBasis(rawValue: defaults.string(forKey: "fertilizerRateBasis") ?? "") ?? .perTwoGallons
        var setup = IrrigationSetup(name: "My drip system")
        setup.directFlowGPH = defaults.double(forKey: "flowRate")
        setup.disc = FlowDisc(rawValue: defaults.string(forKey: "selectedDisc") ?? "") ?? .white
        setup.feedSetting = FeedSetting(rawValue: defaults.string(forKey: "selectedSetting") ?? "") ?? .fast
        setup.tankSize = TankSize(rawValue: defaults.string(forKey: "tankSize") ?? "") ?? .twoAndHalfGallons
        setup.wateringIntervalDays = (1...14).contains(defaults.integer(forKey: "wateringIntervalDays"))
            ? defaults.integer(forKey: "wateringIntervalDays") : 2
        setup.minutesPerSession = defaults.object(forKey: "minutesPerSession") as? Double ?? 30
        setup.firstFeedingOfSeason = defaults.bool(forKey: "isFirstApplication")
        setup.fertilizerID = fertilizer.id
        persist(SavedLibrary(setups: [setup], fertilizers: [fertilizer]))
    }
}
