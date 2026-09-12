import SwiftUI
import UIKit

struct ContentView: View {
    @State private var flowRate = 104.0
    @State private var selectedDisc: FlowDisc = .white
    @State private var selectedSetting: FeedSetting = .fast
    @State private var fertilizerAmount = 2.0
    @State private var fertilizerUnit: FertilizerRateUnit = .teaspoon
    @State private var fertilizerRateBasis: FertilizerRateBasis = .perTwoGallons
    @State private var wateringIntervalDays = 2
    @State private var minutesPerSession = 30.0
    @State private var tankSize: TankSize = .twoAndHalfGallons
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
            minutesPerSession: minutesPerSession,
            tankSize: tankSize
        )
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { scrollProxy in
                Form {
                    TankSection(tankSize: $tankSize)
                        .onChange(of: tankSize, dismissKeyboard)
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
                    GuidanceSection()
                }
                .navigationTitle("EZ-Flow Calculator")
                .scrollDismissesKeyboard(.interactively)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done", action: dismissKeyboard)
                    }
                }
                .onChange(of: focusedField) {
                    revealFocusedField(using: scrollProxy)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
                    // Repeat after the keyboard has resized the form's visible area.
                    revealFocusedField(using: scrollProxy)
                }
            }
        }
    }

    private func revealFocusedField(using scrollProxy: ScrollViewProxy) {
        guard let focusedField else { return }
        withAnimation {
            scrollProxy.scrollTo(focusedField, anchor: .center)
        }
    }

    private func dismissKeyboard() {
        focusedField = nil
    }
}

#Preview {
    ContentView()
}
