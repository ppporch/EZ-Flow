import Foundation
import Testing
@testable import EZFlowCalculator

struct DripConfigurationTests {
    @Test func mixedDrippersAndLinesAddOnlyWhenSelected() {
        let drippers = DripComponent(name: "High-flow bed", count: 10, emitterGPH: 2)
        let line = DripComponent(name: "Line bed", kind: .dripLine, lengthFeet: 20, spacingInches: 12, emitterGPH: 1)
        var setup = IrrigationSetup(name: "Garden", flowMode: .components, directFlowGPH: 104, components: [drippers, line])
        #expect(drippers.flowGPH == 20)
        #expect(line.estimatedEmitters == 20)
        #expect(line.flowGPH == 20)
        #expect(setup.flowGPH == 40)
        #expect(setup.hasValidFlow)
        setup.flowMode = .direct
        #expect(setup.flowGPH == 104)
        #expect(setup.components.count == 2)
        setup.flowMode = .components
        setup.components[0].emitterGPH = 4
        #expect(setup.flowGPH == 60)
    }

    @Test func dripLineUsesFeetAndInchesAndPreservesEstimate() {
        let line = DripComponent(name: "Bed", kind: .dripLine, lengthFeet: 25, spacingInches: 18, emitterGPH: 0.5)
        #expect(abs(line.estimatedEmitters - 16.6666666667) < 0.000001)
        #expect(abs(line.flowGPH - 8.3333333333) < 0.000001)
        #expect(line.isValid)
    }

    @Test(arguments: [0.0, -1, Double.infinity, Double.nan])
    func invalidSpacingAndFlowAreRejected(value: Double) {
        var line = DripComponent(name: "Bed", kind: .dripLine, spacingInches: value)
        #expect(line.isValid == false)
        line.spacingInches = 12
        line.emitterGPH = value
        #expect(line.isValid == false)
        let setup = IrrigationSetup(name: "Bed", directFlowGPH: value)
        #expect(setup.hasValidFlow == false)
    }

    @Test func emptyOrInvalidGroupCannotBeUsedAsFlow() {
        var setup = IrrigationSetup(name: "Bed", flowMode: .components)
        #expect(setup.hasValidFlow == false)
        setup.components = [DripComponent(name: "Bed", count: 0)]
        #expect(setup.hasValidFlow == false)
        let shortLine = DripComponent(name: "Bed", kind: .dripLine, lengthFeet: 0.5, spacingInches: 12)
        #expect(shortLine.isValid == false)
    }

    @Test(arguments: [
        (7.5, FlowDisc.red), (29.99, .red), (30, .black), (59.99, .black),
        (60, .white), (119.99, .white), (120, .none), (1000, .none)
    ])
    func recommendationsMatchFlowGuidelines(flow: Double, disc: FlowDisc) {
        #expect(FlowDisc.recommended(for: flow) == disc)
        #expect(disc.isFlowInRange(flow))
    }

    @Test(arguments: [0.0, 7.49, -1, Double.nan, Double.infinity])
    func unsupportedFlowHasNoRecommendation(flow: Double) {
        #expect(FlowDisc.recommended(for: flow) == nil)
    }

    @Test func recommendationDoesNotChangeInstalledEquipment() {
        let setup = IrrigationSetup(name: "Bed", disc: .white, directFlowGPH: 40)
        #expect(FlowDisc.recommended(for: setup.flowGPH) == .black)
        #expect(setup.disc == .white)
    }

    @Test(arguments: TankSize.allCases)
    func discDilutionNeedsRoomForThreePartsWater(size: TankSize) {
        let fertilizer = FertilizerProfile(name: "Liquid", kind: .liquid, amount: 8, unit: .teaspoon, basis: .perGallon)
        let setup = IrrigationSetup(name: "Bed", tankSize: size, disc: .white)
        let full = setup.calculation(for: fertilizer)
        #expect(full.exceedsTankCapacity == false)
        #expect(full.exceedsDilutionCapacity)
        var firstSetup = setup
        firstSetup.firstFeedingOfSeason = true
        let first = firstSetup.calculation(for: fertilizer)
        #expect(first.exceedsDilutionCapacity == false)
        #expect(first.productTeaspoons == full.productTeaspoons / 2)
    }
}
