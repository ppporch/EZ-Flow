import Foundation

struct EZFlowCalculation {
    let flowRateGPH: Double
    let feedSetting: FeedSetting
    let flowDisc: FlowDisc
    let fertilizerAmount: Double
    let fertilizerUnit: FertilizerRateUnit
    let fertilizerRateBasis: FertilizerRateBasis
    let wateringIntervalDays: Double
    let minutesPerSession: Double
    let tankSize: TankSize

    init(
        flowRateGPH: Double,
        feedSetting: FeedSetting,
        flowDisc: FlowDisc,
        fertilizerAmount: Double,
        fertilizerUnit: FertilizerRateUnit,
        fertilizerRateBasis: FertilizerRateBasis = .perGallon,
        wateringIntervalDays: Double = 0,
        minutesPerSession: Double = 0,
        tankSize: TankSize = .twoAndHalfGallons
    ) {
        self.flowRateGPH = max(flowRateGPH, 0)
        self.feedSetting = feedSetting
        self.flowDisc = flowDisc
        self.fertilizerAmount = max(fertilizerAmount, 0)
        self.fertilizerUnit = fertilizerUnit
        self.fertilizerRateBasis = fertilizerRateBasis
        self.wateringIntervalDays = max(wateringIntervalDays, 0)
        self.minutesPerSession = max(minutesPerSession, 0)
        self.tankSize = tankSize
    }

    var ratio: Double {
        feedSetting.ratio(using: flowDisc)
    }

    var gallonsToEmpty: Double {
        tankSize.gallons * ratio
    }

    var runtimeHours: Double {
        guard flowRateGPH > 0 else { return 0 }
        return gallonsToEmpty / flowRateGPH
    }

    var runtimeMinutes: Int? {
        Int(exactly: (runtimeHours * 60).rounded())
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

    var exceedsTankCapacity: Bool {
        productGallons > tankSize.gallons
    }
}
