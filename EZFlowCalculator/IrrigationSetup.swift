import Foundation

struct IrrigationSetup: Codable, Equatable, Identifiable {
    var id = UUID()
    var name = ""
    var tankSize: TankSize = .twoAndHalfGallons
    var disc: FlowDisc = .white
    var feedSetting: FeedSetting = .fast
    var flowMode: FlowInputMode = .direct
    var directFlowGPH = 104.0
    var components: [DripComponent] = []
    var fertilizerID: UUID?
    var firstFeedingOfSeason = false
    var wateringIntervalDays = 2
    var minutesPerSession = 30.0

    var flowGPH: Double {
        flowMode == .direct ? directFlowGPH : components.reduce(0) { $0 + $1.flowGPH }
    }

    var hasValidFlow: Bool {
        flowGPH.isFinite && flowGPH > 0 &&
        (flowMode == .direct || (!components.isEmpty && components.allSatisfy(\.isValid)))
    }

    func canCalculate(with fertilizer: FertilizerProfile?) -> Bool {
        guard let fertilizer else { return false }
        return hasValidFlow && fertilizer.id == fertilizerID && fertilizer.isValid
    }

    func calculation(for fertilizer: FertilizerProfile) -> EZFlowCalculation {
        EZFlowCalculation(
            flowRateGPH: flowGPH, feedSetting: feedSetting, flowDisc: disc,
            fertilizerAmount: fertilizer.amount, fertilizerUnit: fertilizer.unit,
            fertilizerRateBasis: fertilizer.basis, wateringIntervalDays: Double(wateringIntervalDays),
            minutesPerSession: minutesPerSession, tankSize: tankSize,
            isFirstApplication: firstFeedingOfSeason
        )
    }
}
