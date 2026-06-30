import Foundation

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
        self.flowRateGPH = max(flowRateGPH, 0)
        self.feedSetting = feedSetting
        self.flowDisc = flowDisc
        self.fertilizerAmount = max(fertilizerAmount, 0)
        self.fertilizerUnit = fertilizerUnit
        self.fertilizerRateBasis = fertilizerRateBasis
        self.wateringIntervalDays = max(wateringIntervalDays, 0)
        self.minutesPerSession = max(minutesPerSession, 0)
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
