import SwiftUI

struct IrrigationSection: View {
    @Binding var flowRate: Double
    @Binding var selectedDisc: FlowDisc
    let focusedField: FocusState<FocusedField?>.Binding

    private var flowDiscMessageColor: Color {
        selectedDisc.isFlowInRange(flowRate) ? .green : .orange
    }

    var body: some View {
        Section("Irrigation") {
            HStack {
                Text("Flow rate")
                Spacer()
                TextField("104", value: $flowRate, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .accessibilityLabel("Flow rate in gallons per hour")
                    .focused(focusedField, equals: .flowRate)
                    .selectAllOnFocus(focusedField, equals: .flowRate)
                    .submitLabel(.done)
                    .onSubmit(dismissKeyboard)
                    .frame(maxWidth: 90)
                Text("GPH")
                    .foregroundStyle(.secondary)
            }
            .id(FocusedField.flowRate)

            Picker("Flo-Disc", selection: $selectedDisc) {
                ForEach(FlowDisc.allCases) { disc in
                    Text(disc.displayName).tag(disc)
                }
            }
            .onChange(of: selectedDisc, dismissKeyboard)

            Text(selectedDisc.flowMessage(for: flowRate))
                .font(.footnote)
                .foregroundStyle(flowDiscMessageColor)
        }
    }

    private func dismissKeyboard() {
        focusedField.wrappedValue = nil
    }
}
