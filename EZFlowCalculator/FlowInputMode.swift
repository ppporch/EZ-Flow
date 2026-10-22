import Foundation

enum FlowInputMode: String, Codable, CaseIterable, Identifiable {
    case direct
    case components

    var id: String { rawValue }
    var title: LocalizedStringResource {
        switch self {
        case .direct: "Enter total flow"
        case .components: "Calculate from drippers & lines"
        }
    }
}
