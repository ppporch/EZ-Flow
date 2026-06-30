enum FertilizerRateBasis: String, CaseIterable, Identifiable {
    case perGallon = "per gal"
    case perTwoGallons = "per 2 gal"

    var id: String { rawValue }

    var gallons: Double {
        switch self {
        case .perGallon:
            1
        case .perTwoGallons:
            2
        }
    }
}
