import Foundation

struct DripComponent: Codable, Equatable, Identifiable {
    var id = UUID()
    var name = ""
    var kind: DripComponentKind = .drippers
    var count = 1
    var lengthFeet = 10.0
    var spacingInches = 12.0
    var emitterGPH = 1.0

    // Length / spacing estimates emitters. Actual counts can differ at cut ends.
    var estimatedEmitters: Double {
        kind == .drippers ? Double(count) : lengthFeet * 12 / spacingInches
    }

    var flowGPH: Double { estimatedEmitters * emitterGPH }

    var isValid: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              emitterGPH.isFinite, emitterGPH > 0 else { return false }
        switch kind {
        case .drippers: return count > 0 && flowGPH.isFinite
        case .dripLine:
            return lengthFeet.isFinite && lengthFeet > 0 && spacingInches.isFinite && spacingInches > 0
                && estimatedEmitters >= 1 && flowGPH.isFinite
        }
    }
}
