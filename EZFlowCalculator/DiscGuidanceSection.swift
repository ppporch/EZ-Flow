import SwiftUI

struct DiscGuidanceSection: View {
    let flowGPH: Double
    @Binding var installedDisc: FlowDisc
    let onConfirmInstallation: (FlowDisc) -> Void

    private var recommendation: FlowDisc? { FlowDisc.recommended(for: flowGPH) }

    var body: some View {
        Section("Installed Flo-Disc") {
            Picker("Disc in your injector", selection: $installedDisc) {
                ForEach(FlowDisc.allCases) { disc in Text(disc.displayName).tag(disc) }
            }
            Label(installedDisc.flowMessage(for: flowGPH),
                  systemImage: installedDisc.isFlowInRange(flowGPH) ? "checkmark.circle" : "exclamationmark.triangle")
                .font(.footnote).foregroundStyle(installedDisc.isFlowInRange(flowGPH) ? Color.secondary : .orange)
            if !installedDisc.isFlowInRange(flowGPH), let recommendation {
                Text(recommendation == .none
                     ? "At this flow, operation without a Flo-Disc is a starting point. Confirm injection by color."
                     : "For this flow, the \(recommendation.displayName) Flo-Disc is a starting point. Confirm injection by color after installation.")
                    .font(.footnote)
                Button(recommendation == .none ? "I've removed the Flo-Disc" : "I've installed \(recommendation.displayName)") {
                    onConfirmInstallation(recommendation)
                }
            } else if recommendation == nil, flowGPH > 0 {
                Text("Below 7.5 GPH, none of the supplied disc ranges applies. Check the system with EZ-FLO before relying on the estimate.")
                    .font(.footnote).foregroundStyle(.orange)
            }
            DisclosureGroup("Disc ranges and changing a disc") {
                Text("No disc: 120 GPH and above\nWhite: 60–120 GPH\nBlack: 30–60 GPH\nRed: 7.5–30 GPH")
                Text("Shut off water and release tank pressure before changing a disc. Remove the hose-bib washer, fit the disc against the flow restrictor, and replace the washer. Restore flow and check for fertilizer color in the clear outlet tube. A disc is not a pressure regulator.")
                Text("Advice does not change your saved disc. Select the new disc only after it is installed.")
            }
            .font(.footnote)
        }
    }
}
