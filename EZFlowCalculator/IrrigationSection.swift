import SwiftUI

struct IrrigationSection: View {
    @Binding var flowRate: Double
    @Binding var selectedDisc: FlowDisc
    let focusedField: FocusState<FocusedField?>.Binding

    private var flowDiscMessageColor: Color {
        guard let range = selectedDisc.flowRange else { return .secondary }
        return range.contains(flowRate) ? .green : .orange
    }

    var body: some View {
        Section("Irrigation") {
            HStack {
                Text("Flow rate")
                Spacer()
                TextField("104", value: $flowRate, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .focused(focusedField, equals: .flowRate)
                    .submitLabel(.done)
                    .onSubmit(dismissKeyboard)
                    .frame(maxWidth: 90)
                Text("GPH")
                    .foregroundStyle(.secondary)
            }

            Picker("Flo-Disc", selection: $selectedDisc) {
                ForEach(FlowDisc.allCases) { disc in
                    Text(disc.rawValue).tag(disc)
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
