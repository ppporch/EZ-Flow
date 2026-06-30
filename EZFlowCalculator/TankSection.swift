import SwiftUI

struct TankSection: View {
    var body: some View {
        Section("Tank") {
            LabeledContent("Model", value: "EZ 2020-HB")
            LabeledContent("Tank size", value: "2.5 gal")
            LabeledContent("Usable liquid mix", value: "2.0 gal")
        }
    }
}
