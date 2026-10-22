import Foundation

struct FertilizerProfile: Codable, Identifiable, Equatable {
    var id = UUID()
    var name = ""
    var kind: FertilizerKind = .solublePowder
    var amount = 2.0
    var unit: FertilizerRateUnit = .teaspoon
    var basis: FertilizerRateBasis = .perTwoGallons

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && amount.isFinite && amount > 0
            && (kind == .liquid || unit != .fluidOunce)
    }

    var rateDescription: String {
        "\(amount.formatted()) \(unit.displayName) \(basis.displayName)"
    }
}
