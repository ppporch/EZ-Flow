import SwiftUI

struct SettingSection: View {
    @Binding var selectedSetting: FeedSetting

    let calculation: EZFlowCalculation
    let focusedField: FocusState<FocusedField?>.Binding

    var body: some View {
        Section("EZ-Flow Setting") {
            Picker("Feed rate", selection: $selectedSetting) {
                ForEach(FeedSetting.allCases) { setting in
                    Text(setting.displayName).tag(setting)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedSetting, dismissKeyboard)

            LabeledContent("Injection ratio", value: "\(calculation.ratio.formatted(.number.precision(.fractionLength(0...1)))):1")
            LabeledContent("Water until fertilizer is used up", value: "\(calculation.gallonsToEmpty.formatted(.number.precision(.fractionLength(0...1)))) gal")
            LabeledContent("Feeding runtime", value: runtimeText)
        }
    }

    private var runtimeText: String {
        guard calculation.flowRateGPH > 0 else { return "Enter flow" }
        guard let totalMinutes = calculation.runtimeMinutes else { return "Check flow rate" }
        guard totalMinutes > 0 else { return "Less than 1 min" }

        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours == 0 {
            return "\(minutes) min"
        }

        if minutes == 0 {
            return "\(hours) hr"
        }

        return "\(hours) hr \(minutes) min"
    }

    private func dismissKeyboard() {
        focusedField.wrappedValue = nil
    }
}
