import Foundation

enum FertilizerKind: String, Codable, CaseIterable, Identifiable {
    case liquid
    case solublePowder

    var id: String { rawValue }
    var title: LocalizedStringResource {
        switch self {
        case .liquid: "Liquid"
        case .solublePowder: "Water-soluble powder"
        }
    }
}
