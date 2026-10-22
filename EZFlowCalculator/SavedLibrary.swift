import Foundation

struct SavedLibrary: Codable, Equatable {
    var version = 1
    var setups: [IrrigationSetup] = []
    var fertilizers: [FertilizerProfile] = []
}
