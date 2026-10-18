import Foundation

enum FertilizerRateUnit: String, CaseIterable, Identifiable {
    case teaspoon
    case tablespoon
    case fluidOunce
    case cup

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .teaspoon: "tsp"
        case .tablespoon: "Tbsp"
        case .fluidOunce: "fl oz"
        case .cup: "cup"
        }
    }

    func formattedAmount(teaspoons amount: Double) -> String {
        let value = amount / teaspoons
        let unit = self == .cup && value != 1 ? "cups" : displayName
        return "\(value.formatted(.number.precision(.fractionLength(0...2)))) \(unit)"
    }

    var teaspoons: Double {
        switch self {
        case .teaspoon:
            1
        case .tablespoon:
            3
        case .fluidOunce:
            6
        case .cup:
            48
        }
    }
}
