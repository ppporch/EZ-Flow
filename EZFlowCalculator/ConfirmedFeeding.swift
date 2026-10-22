import Foundation

/// Captures the settings accepted by the user, so an open result stays consistent.
struct ConfirmedFeeding: Identifiable {
    let id = UUID()
    let setup: IrrigationSetup
    let fertilizer: FertilizerProfile
}
