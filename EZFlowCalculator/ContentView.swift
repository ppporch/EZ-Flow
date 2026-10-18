import SwiftUI
import UIKit

struct ContentView: View {
    @AppStorage("flowRate") private var flowRate = 104.0
    @AppStorage("selectedDisc") private var selectedDisc: FlowDisc = .white
    @AppStorage("selectedSetting") private var selectedSetting: FeedSetting = .fast
    @AppStorage("fertilizerAmount") private var fertilizerAmount = 2.0
    @AppStorage("fertilizerUnit") private var fertilizerUnit: FertilizerRateUnit = .teaspoon
    @AppStorage("fertilizerRateBasis") private var fertilizerRateBasis: FertilizerRateBasis = .perTwoGallons
    @AppStorage("wateringIntervalDays") private var wateringIntervalDays = 2
    @AppStorage("minutesPerSession") private var minutesPerSession = 30.0
    @AppStorage("tankSize") private var tankSize: TankSize = .twoAndHalfGallons
    @State private var isFirstApplication = false
    @State private var showingSchedule = false
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
            tankSize: tankSize,
            isFirstApplication: isFirstApplication
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
                    FertilizerSection(
                        fertilizerAmount: $fertilizerAmount,
                        fertilizerUnit: $fertilizerUnit,
                        fertilizerRateBasis: $fertilizerRateBasis,
                        isFirstApplication: $isFirstApplication,
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
                    Section {
                        DisclosureGroup("Watering schedule and estimates", isExpanded: $showingSchedule) {
                            WateringScheduleSection(
                                wateringIntervalDays: $wateringIntervalDays,
                                minutesPerSession: $minutesPerSession,
                                focusedField: $focusedField
                            )
                            ScheduleResultSection(calculation: calculation)
                        }
                        .onChange(of: showingSchedule, dismissKeyboard)
                    }
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
