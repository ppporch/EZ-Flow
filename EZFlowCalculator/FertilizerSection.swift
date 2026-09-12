import SwiftUI
import UIKit

struct FertilizerSection: View {
    @Binding var fertilizerAmount: Double
    @Binding var fertilizerUnit: FertilizerRateUnit
    @Binding var fertilizerRateBasis: FertilizerRateBasis

    let calculation: EZFlowCalculation
    let presets: [FertilizerPreset]
    let focusedField: FocusState<FocusedField?>.Binding

    var body: some View {
        Section("Fertilizer Rate") {
            HStack {
                TextField("Amount", value: $fertilizerAmount, format: .number)
                    .keyboardType(.decimalPad)
                    .focused(focusedField, equals: .fertilizerAmount)
                    .onChange(of: focusedField.wrappedValue) {
                        guard focusedField.wrappedValue == .fertilizerAmount else { return }
                        // Select after the tap has finished placing the insertion point.
                        DispatchQueue.main.async {
                            guard focusedField.wrappedValue == .fertilizerAmount else { return }
                            UIApplication.shared.sendAction(
                                #selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil
                            )
                        }
                    }
                    .submitLabel(.done)
                    .onSubmit(dismissKeyboard)
                Picker("Unit", selection: $fertilizerUnit) {
                    ForEach(FertilizerRateUnit.allCases) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .labelsHidden()
                .onChange(of: fertilizerUnit, dismissKeyboard)
                Picker("Basis", selection: $fertilizerRateBasis) {
                    ForEach(FertilizerRateBasis.allCases) { basis in
                        Text(basis.rawValue).tag(basis)
                    }
                }
                .labelsHidden()
                .onChange(of: fertilizerRateBasis, dismissKeyboard)
            }
            .id(FocusedField.fertilizerAmount)

            LabeledContent("Normalized rate", value: "\(calculation.fertilizerTeaspoonsPerGallon.formatted(.number.precision(.fractionLength(1...2)))) tsp/gal")

            ScrollView(.horizontal) {
                HStack {
                    ForEach(presets) { preset in
                        Button(preset.title) {
                            apply(preset)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.vertical, 4)
            }
            .scrollIndicators(.hidden)
        }
    }

    private func apply(_ preset: FertilizerPreset) {
        focusedField.wrappedValue = nil
        fertilizerAmount = preset.amount
        fertilizerUnit = preset.unit
        fertilizerRateBasis = preset.basis
    }

    private func dismissKeyboard() {
        focusedField.wrappedValue = nil
    }
}
