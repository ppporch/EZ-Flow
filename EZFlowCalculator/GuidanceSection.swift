import SwiftUI

struct GuidanceSection: View {
    let calculation: EZFlowCalculation
    let selectedDisc: FlowDisc

    var body: some View {
        Section("Checks") {
            if calculation.exceedsTankCapacity {
                Label("This application rate requires more than 2 gallons of product. Use a stronger EZ-Flow setting or split the application.", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            }

            if calculation.exceedsFloDiscPremixGuidance {
                Label("With a Flo-Disc, the manual recommends a 25% product mix. This result is above that guidance.", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            } else if selectedDisc.hasDisc {
                Label("Flo-Disc setup: add product, then water to make 2.0 gallons total mix.", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }

            Text("First application: EZ-FLO recommends starting at half of the fertilizer label rate.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
