import Testing
@testable import EZFlowCalculator

struct EZFlowCalculatorTests {
    @Test func whiteDiscFastOneTeaspoonPerGallon() {
        let calculation = EZFlowCalculation(
            flowRateGPH: 104,
            feedSetting: .fast,
            flowDisc: .white,
            fertilizerAmount: 1,
            fertilizerUnit: .teaspoon
        )

        #expect(calculation.ratio == 25)
        #expect(calculation.gallonsToEmpty == 50)
        #expect(calculation.productTeaspoons == 50)
        #expect(calculation.productTablespoons.isClose(to: 50.0 / 3.0))
        #expect(calculation.productFluidOunces.isClose(to: 50.0 / 6.0))
        #expect(calculation.runtimeHours.isClose(to: 50.0 / 104.0))
    }

    @Test func noDiscSlowUsesStandardManualRatio() {
        let calculation = EZFlowCalculation(
            flowRateGPH: 104,
            feedSetting: .slow,
            flowDisc: .none,
            fertilizerAmount: 1,
            fertilizerUnit: .tablespoon
        )

        #expect(calculation.ratio == 1000)
        #expect(calculation.gallonsToEmpty == 2000)
        #expect(calculation.productTeaspoons == 6000)
    }

    @Test func whiteDiscFlowRangeIncludes104GPH() throws {
        let range = try #require(FlowDisc.white.flowRange)

        #expect(range == 60...120)
        #expect(range.contains(104))
    }

    @Test func scheduleEstimatesAtDefaultFlow() {
        let calculation = EZFlowCalculation(
            flowRateGPH: 104,
            feedSetting: .fast,
            flowDisc: .white,
            fertilizerAmount: 1,
            fertilizerUnit: .teaspoon,
            wateringIntervalDays: 2,
            minutesPerSession: 30
        )

        #expect(calculation.gallonsPerSession.isClose(to: 52))
        #expect(calculation.sessionsPerWeek.isClose(to: 3.5))
        #expect(calculation.gallonsPerWeek.isClose(to: 182))
        #expect(calculation.productTeaspoonsPerSession.isClose(to: 52))
        #expect(calculation.productTeaspoonsPerWeek.isClose(to: 182))
        #expect(calculation.sessionsToEmpty.isClose(to: 50.0 / 52.0))
        #expect(calculation.weeksToEmpty.isClose(to: 50.0 / 182.0))
    }

    @Test func twoGallonRateBasisNormalizesToPerGallon() {
        let calculation = EZFlowCalculation(
            flowRateGPH: 104,
            feedSetting: .fast,
            flowDisc: .white,
            fertilizerAmount: 2,
            fertilizerUnit: .teaspoon,
            fertilizerRateBasis: .perTwoGallons
        )

        #expect(calculation.fertilizerTeaspoonsPerGallon == 1)
        #expect(calculation.productTeaspoons == 50)
    }

    @Test func negativeInputsAreClampedToZero() {
        let calculation = EZFlowCalculation(
            flowRateGPH: -104,
            feedSetting: .fast,
            flowDisc: .white,
            fertilizerAmount: -2,
            fertilizerUnit: .teaspoon,
            wateringIntervalDays: -2,
            minutesPerSession: -30
        )

        #expect(calculation.flowRateGPH == 0)
        #expect(calculation.fertilizerAmount == 0)
        #expect(calculation.wateringIntervalDays == 0)
        #expect(calculation.minutesPerSession == 0)
        #expect(calculation.runtimeHours == 0)
        #expect(calculation.productTeaspoons == 0)
        #expect(calculation.sessionsPerWeek == 0)
    }
}

private extension Double {
    func isClose(to other: Double, tolerance: Double = 0.001) -> Bool {
        abs(self - other) < tolerance
    }
}
