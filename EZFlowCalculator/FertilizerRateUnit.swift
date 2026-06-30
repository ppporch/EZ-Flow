enum FertilizerRateUnit: String, CaseIterable, Identifiable {
    case teaspoon = "tsp"
    case tablespoon = "Tbsp"
    case fluidOunce = "fl oz"
    case cup = "cup"

    var id: String { rawValue }

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
