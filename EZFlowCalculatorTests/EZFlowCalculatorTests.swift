import PDFKit
import Testing
@testable import EZFlowCalculator

struct EZFlowCalculatorTests {
    @Test(arguments: FlowDisc.allCases)
    func smallTankUsesItsOwnChartColumn(disc: FlowDisc) {
        // Exact products; the printed chart rounds some entries (and prints 50 for 62.5 × .75).
        let expected: [Double] = disc.hasDisc ? [187.5, 93.75, 46.875, 18.75] : [750, 375, 187.5, 75]
        for (setting, gallons) in zip(FeedSetting.allCases, expected) {
            let calculation = EZFlowCalculation(
                flowRateGPH: 104, feedSetting: setting, flowDisc: disc,
                fertilizerAmount: 1, fertilizerUnit: .teaspoon,
                wateringIntervalDays: 2, minutesPerSession: 30,
                tankSize: .threeQuarterGallon
            )
            #expect(calculation.gallonsToEmpty == gallons)
            #expect(calculation.productTeaspoons == gallons)
            #expect(calculation.runtimeHours.isClose(to: gallons / 104))
            #expect(calculation.sessionsToEmpty.isClose(to: gallons / 52))
            #expect(calculation.weeksToEmpty.isClose(to: gallons / 182))
            #expect(calculation.productTeaspoonsPerSession == 52)
        }
    }

    @Test(arguments: TankSize.allCases)
    func selectedTankControlsCapacityCheck(size: TankSize) {
        let basis = size.gallons
        let rate = size.gallons * 768 / (basis * 100)
        let atLimit = EZFlowCalculation(
            flowRateGPH: 104, feedSetting: .fast, flowDisc: .none,
            fertilizerAmount: rate, fertilizerUnit: .teaspoon, tankSize: size
        )
        let overLimit = EZFlowCalculation(
            flowRateGPH: 104, feedSetting: .fast, flowDisc: .none,
            fertilizerAmount: rate * 1.01, fertilizerUnit: .teaspoon, tankSize: size
        )
        #expect(atLimit.exceedsTankCapacity == false)
        #expect(overLimit.exceedsTankCapacity)
    }

    @Test(arguments: FlowDisc.allCases)
    func largeTankUsesFeedingChart(disc: FlowDisc) {
        let expected: [Double] = disc.hasDisc ? [625, 312.5, 156.25, 62.5] : [2500, 1250, 625, 250]
        for (setting, gallons) in zip(FeedSetting.allCases, expected) {
            let calculation = EZFlowCalculation(
                flowRateGPH: 104, feedSetting: setting, flowDisc: disc,
                fertilizerAmount: 1, fertilizerUnit: .teaspoon,
                tankSize: .twoAndHalfGallons
            )
            #expect(calculation.gallonsToEmpty == gallons)
            #expect(calculation.productTeaspoons == gallons)
        }
    }

    @Test func feedingChartIsBundledAndReadable() throws {
        let url = try #require(FeedingChart.url)
        let document = try #require(PDFDocument(url: url))
        #expect(document.pageCount == 2)
        let text = try #require(document.string)
        #expect(text.contains("2020-HB"))
        #expect(text.contains("2005-HB"))
    }

    @Test func tinyFlowCannotOverflowRuntimeFormatting() {
        let calculation = EZFlowCalculation(
            flowRateGPH: 0.0000000000000001, feedSetting: .fast, flowDisc: .white,
            fertilizerAmount: 1, fertilizerUnit: .teaspoon
        )
        #expect(calculation.runtimeMinutes == nil)
    }

    @Test func longSessionNeedsMoreThanOneCharge() {
        let calculation = EZFlowCalculation(
            flowRateGPH: 104, feedSetting: .fast, flowDisc: .white,
            fertilizerAmount: 1, fertilizerUnit: .teaspoon,
            wateringIntervalDays: 2, minutesPerSession: 60
        )
        #expect(calculation.productTeaspoons == 62.5)
        #expect(calculation.productTeaspoonsPerSession == 104)
        #expect(calculation.sessionsToEmpty < 1)
    }

    @Test func whiteDiscFastOneTeaspoonPerGallon() {
        let calculation = EZFlowCalculation(
            flowRateGPH: 104,
            feedSetting: .fast,
            flowDisc: .white,
            fertilizerAmount: 1,
            fertilizerUnit: .teaspoon
        )

        #expect(calculation.ratio == 25)
        #expect(calculation.gallonsToEmpty == 62.5)
        #expect(calculation.productTeaspoons == 62.5)
        #expect(calculation.productTablespoons.isClose(to: 62.5 / 3.0))
        #expect(calculation.productFluidOunces.isClose(to: 62.5 / 6.0))
        #expect(calculation.runtimeHours.isClose(to: 62.5 / 104.0))
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
        #expect(calculation.gallonsToEmpty == 2500)
        #expect(calculation.productTeaspoons == 7500)
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
        #expect(calculation.sessionsToEmpty.isClose(to: 62.5 / 52.0))
        #expect(calculation.weeksToEmpty.isClose(to: 62.5 / 182.0))
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
        #expect(calculation.productTeaspoons == 62.5)
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
