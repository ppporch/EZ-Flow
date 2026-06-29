import XCTest

final class EZFlowCalculatorTests: XCTestCase {
    func testWhiteDiscFastOneTeaspoonPerGallon() {
        let calculation = EZFlowCalculation(
            flowRateGPH: 104,
            feedSetting: .fast,
            flowDisc: .white,
            fertilizerAmount: 1,
            fertilizerUnit: .teaspoon
        )

        XCTAssertEqual(calculation.ratio, 25)
        XCTAssertEqual(calculation.gallonsToEmpty, 50)
        XCTAssertEqual(calculation.productTeaspoons, 50)
        XCTAssertEqual(calculation.productTablespoons, 50.0 / 3.0, accuracy: 0.001)
        XCTAssertEqual(calculation.productFluidOunces, 50.0 / 6.0, accuracy: 0.001)
        XCTAssertEqual(calculation.runtimeHours, 50.0 / 104.0, accuracy: 0.001)
    }

    func testNoDiscSlowUsesStandardManualRatio() {
        let calculation = EZFlowCalculation(
            flowRateGPH: 104,
            feedSetting: .slow,
            flowDisc: .none,
            fertilizerAmount: 1,
            fertilizerUnit: .tablespoon
        )

        XCTAssertEqual(calculation.ratio, 1000)
        XCTAssertEqual(calculation.gallonsToEmpty, 2000)
        XCTAssertEqual(calculation.productTeaspoons, 6000)
    }

    func testWhiteDiscFlowRangeIncludes104GPH() {
        XCTAssertEqual(FlowDisc.white.flowRange, 60...120)
        XCTAssertTrue(FlowDisc.white.flowRange?.contains(104) == true)
    }

    func testScheduleEstimatesAtDefaultFlow() {
        let calculation = EZFlowCalculation(
            flowRateGPH: 104,
            feedSetting: .fast,
            flowDisc: .white,
            fertilizerAmount: 1,
            fertilizerUnit: .teaspoon,
            wateringIntervalDays: 2,
            minutesPerSession: 30
        )

        XCTAssertEqual(calculation.gallonsPerSession, 52, accuracy: 0.001)
        XCTAssertEqual(calculation.sessionsPerWeek, 3.5, accuracy: 0.001)
        XCTAssertEqual(calculation.gallonsPerWeek, 182, accuracy: 0.001)
        XCTAssertEqual(calculation.productTeaspoonsPerSession, 52, accuracy: 0.001)
        XCTAssertEqual(calculation.productTeaspoonsPerWeek, 182, accuracy: 0.001)
        XCTAssertEqual(calculation.sessionsToEmpty, 50.0 / 52.0, accuracy: 0.001)
        XCTAssertEqual(calculation.weeksToEmpty, 50.0 / 182.0, accuracy: 0.001)
    }

    func testTwoGallonRateBasisNormalizesToPerGallon() {
        let calculation = EZFlowCalculation(
            flowRateGPH: 104,
            feedSetting: .fast,
            flowDisc: .white,
            fertilizerAmount: 2,
            fertilizerUnit: .teaspoon,
            fertilizerRateBasis: .perTwoGallons
        )

        XCTAssertEqual(calculation.fertilizerTeaspoonsPerGallon, 1)
        XCTAssertEqual(calculation.productTeaspoons, 50)
    }
}
