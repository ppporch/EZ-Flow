enum FertilizerRateBasis: String, CaseIterable, Identifiable {
    case perGallon
    case perTwoGallons

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .perGallon: "per gal"
        case .perTwoGallons: "per 2 gal"
        }
    }

    var gallons: Double {
        switch self {
        case .perGallon:
            1
        case .perTwoGallons:
            2
        }
    }
}
