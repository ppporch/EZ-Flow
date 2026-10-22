import Foundation

enum DripComponentKind: String, Codable, CaseIterable, Identifiable {
    case drippers
    case dripLine

    var id: String { rawValue }
    var title: LocalizedStringResource {
        switch self {
        case .drippers: "Individual drippers"
        case .dripLine: "Drip line"
        }
    }
}
