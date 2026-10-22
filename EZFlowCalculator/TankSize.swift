enum TankSize: String, CaseIterable, Identifiable, Codable {
    case twoAndHalfGallons
    case threeQuarterGallon

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .twoAndHalfGallons: "2.5 gallons"
        case .threeQuarterGallon: "¾ gallon"
        }
    }

    var model: String {
        switch self {
        case .twoAndHalfGallons: "EZ 2020-HB"
        case .threeQuarterGallon: "EZ 2005-HB"
        }
    }

    // Nominal tank capacities used by the supplied feeding chart.
    var gallons: Double {
        switch self {
        case .twoAndHalfGallons: 2.5
        case .threeQuarterGallon: 0.75
        }
    }
}
