import SwiftUI

struct FertilizerSection: View {
    @Binding var fertilizerAmount: Double
    @Binding var fertilizerUnit: FertilizerRateUnit
    @Binding var fertilizerRateBasis: FertilizerRateBasis
    @Binding var isFirstApplication: Bool

    let calculation: EZFlowCalculation
    let presets: [FertilizerPreset]
    let focusedField: FocusState<FocusedField?>.Binding

    var body: some View {
        Section("Rate from your fertilizer label") {
            Text("Enter the label’s rate for ordinary watering, before injector concentration. The water volume below is the label’s dilution volume, not your tank size.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading) {
                LabeledContent("Label amount") {
                    TextField("Amount", value: $fertilizerAmount, format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .accessibilityLabel("Fertilizer amount on the label")
                        .focused(focusedField, equals: .fertilizerAmount)
                        .selectAllOnFocus(focusedField, equals: .fertilizerAmount)
                        .submitLabel(.done)
                        .onSubmit(dismissKeyboard)
                }
                Picker("Unit", selection: $fertilizerUnit) {
                    ForEach(FertilizerRateUnit.allCases) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
                .onChange(of: fertilizerUnit, dismissKeyboard)
                Picker("Label water volume", selection: $fertilizerRateBasis) {
                    ForEach(FertilizerRateBasis.allCases) { basis in
                        Text(basis.displayName).tag(basis)
                    }
                }
                .onChange(of: fertilizerRateBasis, dismissKeyboard)
            }
            .id(FocusedField.fertilizerAmount)

            Toggle("First application: 50% of label rate", isOn: $isFirstApplication)
                .onChange(of: isFirstApplication, dismissKeyboard)
            Text("EZ-FLO recommends half the label rate for the first application. Enter the full label rate above; this switch applies the reduction once. Turn it off for later applications at the full label rate.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            LabeledContent("Label rate", value: "\(fertilizerAmount.formatted()) \(fertilizerUnit.displayName) \(fertilizerRateBasis.displayName)")
            LabeledContent("Rate used (\(isFirstApplication ? 50 : 100)%)", value: "\(calculation.effectiveFertilizerAmount.formatted()) \(fertilizerUnit.displayName) \(fertilizerRateBasis.displayName)")
            LabeledContent("Equivalent per gallon", value: "\(calculation.fertilizerTeaspoonsPerGallon.formatted(.number.precision(.fractionLength(1...2)))) tsp/gal")

            Text("Label rate shortcuts")
                .font(.subheadline)
                .foregroundStyle(.secondary)
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
