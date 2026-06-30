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
