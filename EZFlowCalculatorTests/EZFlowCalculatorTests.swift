import PDFKit
import Testing
@testable import EZFlowCalculator

struct EZFlowCalculatorTests {
    @Test(arguments: FertilizerRateUnit.allCases, TankSize.allCases)
    func firstApplicationHalvesProductWithoutChangingCoverage(unit: FertilizerRateUnit, tank: TankSize) {
        let full = EZFlowCalculation(
            flowRateGPH: 104, feedSetting: .fast, flowDisc: .white,
            fertilizerAmount: 2, fertilizerUnit: unit, fertilizerRateBasis: .perTwoGallons,
            wateringIntervalDays: 2, minutesPerSession: 30, tankSize: tank
        )
        let first = EZFlowCalculation(
            flowRateGPH: 104, feedSetting: .fast, flowDisc: .white,
            fertilizerAmount: 2, fertilizerUnit: unit, fertilizerRateBasis: .perTwoGallons,
            wateringIntervalDays: 2, minutesPerSession: 30, tankSize: tank,
            isFirstApplication: true
        )
        #expect(first.fertilizerAmount == 2)
        #expect(first.effectiveFertilizerAmount == 1)
        #expect(first.productTeaspoons == full.productTeaspoons / 2)
        #expect(first.productTeaspoonsPerSession == full.productTeaspoonsPerSession / 2)
        #expect(first.productTeaspoonsPerWeek == full.productTeaspoonsPerWeek / 2)
        #expect(first.productAmountInSelectedUnit == full.productAmountInSelectedUnit / 2)
        #expect(first.runtimeHours == full.runtimeHours)
        #expect(first.sessionsToEmpty == full.sessionsToEmpty)
        #expect(first.weeksToEmpty == full.weeksToEmpty)
    }

    @Test func firstApplicationUsesEffectiveDoseForCapacityCheck() {
        let full = EZFlowCalculation(
            flowRateGPH: 104, feedSetting: .slow, flowDisc: .none,
            fertilizerAmount: 1, fertilizerUnit: .teaspoon
        )
        let first = EZFlowCalculation(
            flowRateGPH: 104, feedSetting: .slow, flowDisc: .none,
            fertilizerAmount: 1, fertilizerUnit: .teaspoon, isFirstApplication: true
        )
        #expect(full.exceedsTankCapacity)
        #expect(first.exceedsTankCapacity == false)
    }

    @Test(arguments: FertilizerRateUnit.allCases, FertilizerRateBasis.allCases)
    func productResultPreservesLabelUnit(unit: FertilizerRateUnit, basis: FertilizerRateBasis) {
        let calculation = EZFlowCalculation(
            flowRateGPH: 104, feedSetting: .fast, flowDisc: .white,
            fertilizerAmount: 2, fertilizerUnit: unit, fertilizerRateBasis: basis
        )
        #expect(calculation.productAmountInSelectedUnit == 125 / basis.gallons)
        #expect(calculation.productInLabelUnitsSummary.contains(" \(unit.displayName)"))
    }

    @Test(arguments: [
        (2.99, FertilizerRateUnit.teaspoon),
        (3.0, .tablespoon),
        (11.99, .tablespoon),
        (12.0, .cup),
        (48.0, .cup),
        (62.5, .cup)
    ])
    func productChoosesPracticalMeasurement(teaspoons: Double, expectedUnit: FertilizerRateUnit) {
        // Fast with a white disc delivers 62.5 gallons from the default tank.
        let calculation = EZFlowCalculation(
            flowRateGPH: 104, feedSetting: .fast, flowDisc: .white,
            fertilizerAmount: teaspoons / 62.5, fertilizerUnit: .teaspoon
        )
        #expect(calculation.preferredProductUnit == expectedUnit)
        #expect(calculation.productTeaspoons.isClose(to: teaspoons))
    }

    @Test func defaultProductShowsCupsWithTeaspoonEquivalent() {
        let calculation = EZFlowCalculation(
            flowRateGPH: 104, feedSetting: .fast, flowDisc: .white,
            fertilizerAmount: 2, fertilizerUnit: .teaspoon, fertilizerRateBasis: .perTwoGallons
        )
        #expect(calculation.productSummary == "1.3 cups")
        #expect(calculation.productInLabelUnitsSummary == "62.5 tsp")
    }

    @Test func liquidProductKeepsFluidOuncesProminent() {
        let calculation = EZFlowCalculation(
            flowRateGPH: 104, feedSetting: .fast, flowDisc: .white,
            fertilizerAmount: 2, fertilizerUnit: .fluidOunce, fertilizerRateBasis: .perTwoGallons
        )
        #expect(calculation.preferredProductUnit == .fluidOunce)
        #expect(calculation.productSummary == "62.5 fl oz")
    }

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

    @Test(arguments: [7.5, 30.0, 60.0, 104.0, 119.99])
    func noDiscWarnsBelowMinimumFlow(flow: Double) {
        #expect(FlowDisc.none.isFlowInRange(flow) == false)
        let message = FlowDisc.none.flowMessage(for: flow)
        #expect(message.contains("below the 120 GPH"))
        #expect(message.contains("A Flo-Disc may be needed"))
    }

    @Test(arguments: [120.0, 120.01, 240.0, 10000.0])
    func noDiscAcceptsMinimumAndHigherFlows(flow: Double) {
        #expect(FlowDisc.none.isFlowInRange(flow))
        #expect(FlowDisc.none.flowMessage(for: flow).contains("Flow meets the 120 GPH"))
    }

    @Test(arguments: [0.0, -1.0, Double.infinity, Double.nan])
    func noDiscRequestsValidFlow(flow: Double) {
        #expect(FlowDisc.none.isFlowInRange(flow) == false)
        #expect(FlowDisc.none.flowMessage(for: flow).contains("Enter a flow greater than 0 GPH"))
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
