import Foundation

enum FertilizerRateUnit: String, CaseIterable, Identifiable {
    case teaspoon = "tsp"
    case tablespoon = "Tbsp"
    case fluidOunce = "fl oz"
    case cup = "cup"

    var id: String { rawValue }

    func formattedAmount(teaspoons amount: Double) -> String {
        let value = amount / teaspoons
        let unit = self == .cup && value != 1 ? "cups" : rawValue
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
