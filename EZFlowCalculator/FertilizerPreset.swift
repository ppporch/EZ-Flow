import Foundation

struct FertilizerPreset: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let amount: Double
    let unit: FertilizerRateUnit
    let basis: FertilizerRateBasis
}
