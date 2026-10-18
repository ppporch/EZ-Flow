import SwiftUI
import UIKit

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
                    .focused(focusedField, equals: .flowRate)
                    .onChange(of: focusedField.wrappedValue) {
                        guard focusedField.wrappedValue == .flowRate else { return }
                        // Select after the tap has finished placing the insertion point.
                        DispatchQueue.main.async {
                            guard focusedField.wrappedValue == .flowRate else { return }
                            UIApplication.shared.sendAction(
                                #selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil
                            )
                        }
                    }
                    .submitLabel(.done)
                    .onSubmit(dismissKeyboard)
                    .frame(maxWidth: 90)
                Text("GPH")
                    .foregroundStyle(.secondary)
            }
            .id(FocusedField.flowRate)

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
