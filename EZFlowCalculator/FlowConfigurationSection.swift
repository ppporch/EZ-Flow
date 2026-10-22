import SwiftUI

struct FlowConfigurationSection: View {
    @Binding var setup: IrrigationSetup
    let onEdit: (DripComponent) -> Void

    var body: some View {
        Section("2. Irrigation flow") {
            Picker("Flow entry", selection: $setup.flowMode) {
                ForEach(FlowInputMode.allCases) { mode in Text(mode.title).tag(mode) }
            }
            if setup.flowMode == .direct {
                DecimalInput(title: "Total flow (GPH)", value: $setup.directFlowGPH)
                Text("Enter the total gallons per hour of everything running through this injector at the same time.")
                    .font(.footnote).foregroundStyle(.secondary)
            } else {
                ForEach(setup.components) { component in
                    Button { onEdit(component) } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(component.name).foregroundStyle(.primary)
                            Text("\(component.flowGPH.formatted(.number.precision(.fractionLength(0...2)))) GPH · \(component.estimatedEmitters.formatted(.number.precision(.fractionLength(0...1)))) emitters\(component.kind == .dripLine ? " (estimated)" : "")")
                                .font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions { Button("Delete", role: .destructive) { setup.components.removeAll { $0.id == component.id } } }
                }
                Button("Add drippers or drip line", systemImage: "plus") { onEdit(DripComponent()) }
                LabeledContent("Total running together", value: "\(setup.flowGPH.formatted(.number.precision(.fractionLength(0...2)))) GPH")
                    .font(.headline)
                Text("Add a group for each emitter flow rating. Line flow = length in feet × 12 ÷ spacing in inches × GPH per emitter. Cut ends can change the actual emitter count; use individual drippers if you know the exact count.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Text("Switching entry methods keeps your saved drippers and lines. Only the selected method contributes to the total.")
                .font(.footnote).foregroundStyle(.secondary)
        }
    }
}
