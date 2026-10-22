import Foundation

enum FlowDisc: String, CaseIterable, Identifiable, Codable {
    case none
    case white
    case black
    case red

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: "No Disc"
        case .white: "White"
        case .black: "Black"
        case .red: "Red"
        }
    }

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

    // EZ-FLO Flo-Disc instructions: below 120 GPH a disc may be needed.
    // https://ezfloinjection.com/wp-content/uploads/2024/10/2021-Instructions-Flo-Disc-Web.pdf
    static let noDiscMinimumFlowGPH = 120.0

    static func recommended(for flow: Double) -> FlowDisc? {
        guard flow.isFinite, flow >= 7.5 else { return nil }
        if flow >= 120 { return FlowDisc.none }
        if flow >= 60 { return .white }
        if flow >= 30 { return .black }
        return .red
    }

    func isFlowInRange(_ gallonsPerHour: Double) -> Bool {
        guard gallonsPerHour.isFinite, gallonsPerHour > 0 else { return false }
        if let flowRange {
            return flowRange.contains(gallonsPerHour)
        }
        return gallonsPerHour >= Self.noDiscMinimumFlowGPH
    }

    func flowMessage(for gallonsPerHour: Double) -> String {
        guard let flowRange else {
            guard gallonsPerHour.isFinite, gallonsPerHour > 0 else {
                return "Enter a flow greater than 0 GPH to check guidance for operation without a Flo-Disc."
            }
            let minimum = Self.noDiscMinimumFlowGPH.formatted(.number.precision(.fractionLength(0)))
            if isFlowInRange(gallonsPerHour) {
                return "No Flo-Disc selected. Flow meets the \(minimum) GPH minimum-flow guideline. Confirm injection by color in the clear outlet tube."
            }
            return "Flow is below the \(minimum) GPH guideline for operation without a Flo-Disc. A Flo-Disc may be needed; check the disc ranges and confirm injection by color in the clear outlet tube."
        }

        if flowRange.contains(gallonsPerHour) {
            return "\(displayName) disc is in range for \(gallonsPerHour.formatted(.number.precision(.fractionLength(0...1)))) GPH."
        }

        return "\(displayName) disc range is \(flowRange.lowerBound.formatted(.number.precision(.fractionLength(0...1))))-\(flowRange.upperBound.formatted(.number.precision(.fractionLength(0...1)))) GPH."
    }
}
