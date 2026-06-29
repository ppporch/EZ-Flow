import Foundation

enum FlowDisc: String, CaseIterable, Identifiable {
    case none = "No Disc"
    case white = "White"
    case black = "Black"
    case red = "Red"

    var id: String { rawValue }

    var hasDisc: Bool {
        self != .none
    }

    var flowRange: ClosedRange<Double>? {
        switch self {
        case .none:
            nil
        case .white:
            60...120
        case .black:
            30...60
        case .red:
            7.5...30
        }
    }

    func flowMessage(for gallonsPerHour: Double) -> String {
        guard let flowRange else {
            return "No Flo-Disc selected."
        }

        if flowRange.contains(gallonsPerHour) {
            return "\(rawValue) disc is in range for \(gallonsPerHour.formatted(.number.precision(.fractionLength(0...1)))) GPH."
        }

        return "\(rawValue) disc range is \(flowRange.lowerBound.formatted(.number.precision(.fractionLength(0...1))))-\(flowRange.upperBound.formatted(.number.precision(.fractionLength(0...1)))) GPH."
    }
}

enum FeedSetting: String, CaseIterable, Identifiable {
    case slow = "Slow"
    case one = "1"
    case two = "2"
    case fast = "Fast"

    var id: String { rawValue }

    func ratio(using flowDisc: FlowDisc) -> Double {
        switch (flowDisc.hasDisc, self) {
        case (false, .slow):
            1000
        case (false, .one):
            500
        case (false, .two):
            250
        case (false, .fast):
            100
        case (true, .slow):
            250
        case (true, .one):
            125
        case (true, .two):
            62.5
        case (true, .fast):
            25
        }
    }
}

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

struct FertilizerPreset: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let amount: Double
    let unit: FertilizerRateUnit
    let basis: FertilizerRateBasis
}

struct EZFlowCalculation {
    static let tankMixCapacityGallons = 2.0

    let flowRateGPH: Double
    let feedSetting: FeedSetting
    let flowDisc: FlowDisc
    let fertilizerAmount: Double
    let fertilizerUnit: FertilizerRateUnit
    let fertilizerRateBasis: FertilizerRateBasis
    let wateringIntervalDays: Double
    let minutesPerSession: Double

    init(
        flowRateGPH: Double,
        feedSetting: FeedSetting,
        flowDisc: FlowDisc,
        fertilizerAmount: Double,
        fertilizerUnit: FertilizerRateUnit,
        fertilizerRateBasis: FertilizerRateBasis = .perGallon,
        wateringIntervalDays: Double = 0,
        minutesPerSession: Double = 0
    ) {
        self.flowRateGPH = flowRateGPH
        self.feedSetting = feedSetting
        self.flowDisc = flowDisc
        self.fertilizerAmount = fertilizerAmount
        self.fertilizerUnit = fertilizerUnit
        self.fertilizerRateBasis = fertilizerRateBasis
        self.wateringIntervalDays = wateringIntervalDays
        self.minutesPerSession = minutesPerSession
    }

    var ratio: Double {
        feedSetting.ratio(using: flowDisc)
    }

    var gallonsToEmpty: Double {
        Self.tankMixCapacityGallons * ratio
    }

    var runtimeHours: Double {
        guard flowRateGPH > 0 else { return 0 }
        return gallonsToEmpty / flowRateGPH
    }

    var fertilizerTeaspoonsPerGallon: Double {
        guard fertilizerRateBasis.gallons > 0 else { return 0 }
        return fertilizerAmount * fertilizerUnit.teaspoons / fertilizerRateBasis.gallons
    }

    var productTeaspoons: Double {
        gallonsToEmpty * fertilizerTeaspoonsPerGallon
    }

    var productCups: Double {
        productTeaspoons / 48
    }

    var productTablespoons: Double {
        productTeaspoons / 3
    }

    var productFluidOunces: Double {
        productTeaspoons / 6
    }

    var productGallons: Double {
        productCups / 16
    }

    var gallonsPerSession: Double {
        guard flowRateGPH > 0, minutesPerSession > 0 else { return 0 }
        return flowRateGPH * minutesPerSession / 60
    }

    var sessionsPerWeek: Double {
        guard wateringIntervalDays > 0 else { return 0 }
        return 7 / wateringIntervalDays
    }

    var gallonsPerWeek: Double {
        gallonsPerSession * sessionsPerWeek
    }

    var productTeaspoonsPerSession: Double {
        gallonsPerSession * fertilizerTeaspoonsPerGallon
    }

    var productFluidOuncesPerSession: Double {
        productTeaspoonsPerSession / 6
    }

    var productTeaspoonsPerWeek: Double {
        productTeaspoonsPerSession * sessionsPerWeek
    }

    var productFluidOuncesPerWeek: Double {
        productTeaspoonsPerWeek / 6
    }

    var sessionsToEmpty: Double {
        guard gallonsPerSession > 0 else { return 0 }
        return gallonsToEmpty / gallonsPerSession
    }

    var weeksToEmpty: Double {
        guard gallonsPerWeek > 0 else { return 0 }
        return gallonsToEmpty / gallonsPerWeek
    }

    var topOffWaterGallons: Double {
        max(Self.tankMixCapacityGallons - productGallons, 0)
    }

    var exceedsTankCapacity: Bool {
        productGallons > Self.tankMixCapacityGallons
    }

    var exceedsFloDiscPremixGuidance: Bool {
        flowDisc.hasDisc && productGallons > Self.tankMixCapacityGallons * 0.25
    }
}
