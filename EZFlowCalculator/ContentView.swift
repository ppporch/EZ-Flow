import SwiftUI

struct ContentView: View {
    @State private var flowRate = 104.0
    @State private var selectedDisc: FlowDisc = .white
    @State private var selectedSetting: FeedSetting = .fast
    @State private var fertilizerAmount = 2.0
    @State private var fertilizerUnit: FertilizerRateUnit = .teaspoon
    @State private var fertilizerRateBasis: FertilizerRateBasis = .perTwoGallons
    @State private var wateringIntervalDays = 2
    @State private var minutesPerSession = 30.0
    @FocusState private var focusedField: FocusedField?

    private let presets: [FertilizerPreset] = [
        FertilizerPreset(title: "2 tsp/2 gal", amount: 2, unit: .teaspoon, basis: .perTwoGallons),
        FertilizerPreset(title: "2 Tbsp/2 gal", amount: 2, unit: .tablespoon, basis: .perTwoGallons),
        FertilizerPreset(title: "4 Tbsp/2 gal", amount: 4, unit: .tablespoon, basis: .perTwoGallons),
        FertilizerPreset(title: "2 fl oz/2 gal", amount: 2, unit: .fluidOunce, basis: .perTwoGallons)
    ]

    private var calculation: EZFlowCalculation {
        EZFlowCalculation(
            flowRateGPH: flowRate,
            feedSetting: selectedSetting,
            flowDisc: selectedDisc,
            fertilizerAmount: fertilizerAmount,
            fertilizerUnit: fertilizerUnit,
            fertilizerRateBasis: fertilizerRateBasis,
            wateringIntervalDays: Double(wateringIntervalDays),
            minutesPerSession: minutesPerSession
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                TankSection()
                IrrigationSection(
                    flowRate: $flowRate,
                    selectedDisc: $selectedDisc,
                    focusedField: $focusedField
                )
                WateringScheduleSection(
                    wateringIntervalDays: $wateringIntervalDays,
                    minutesPerSession: $minutesPerSession,
                    focusedField: $focusedField
                )
                FertilizerSection(
                    fertilizerAmount: $fertilizerAmount,
                    fertilizerUnit: $fertilizerUnit,
                    fertilizerRateBasis: $fertilizerRateBasis,
                    calculation: calculation,
                    presets: presets,
                    focusedField: $focusedField
                )
                SettingSection(
                    selectedSetting: $selectedSetting,
                    calculation: calculation,
                    focusedField: $focusedField
                )
                ProductResultSection(calculation: calculation)
                ScheduleResultSection(calculation: calculation)
                GuidanceSection(calculation: calculation, selectedDisc: selectedDisc)
            }
            .navigationTitle("EZ-Flow Calculator")
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done", action: dismissKeyboard)
                }
            }
        }
    }

    private func dismissKeyboard() {
        focusedField = nil
    }
}

#Preview {
    ContentView()
}
