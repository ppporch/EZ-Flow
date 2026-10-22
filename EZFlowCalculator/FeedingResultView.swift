import SwiftUI

struct FeedingResultView: View {
    let setup: IrrigationSetup
    let fertilizer: FertilizerProfile
    @State private var showingChart = false

    private var calculation: EZFlowCalculation { setup.calculation(for: fertilizer) }

    var body: some View {
        List {
            Section {
                Text(fertilizer.name).font(.headline)
                Text(setup.name).font(.subheadline).foregroundStyle(.secondary)
            }
            ProductResultSection(calculation: calculation)
            Section {
                DisclosureGroup("Settings used") {
                    LabeledContent("Setup", value: setup.name)
                    LabeledContent("Fertilizer", value: fertilizer.name)
                    LabeledContent("Confirmed label rate", value: fertilizer.rateDescription)
                    LabeledContent("Installed disc", value: setup.disc.displayName)
                    LabeledContent("Feed setting", value: setup.feedSetting.displayName)
                    LabeledContent("Flow", value: "\(setup.flowGPH.formatted(.number.precision(.fractionLength(0...2)))) GPH")
                }
                if !setup.disc.isFlowInRange(setup.flowGPH) {
                    Label("The installed disc is outside its flow guideline. Check the disc advice in your setup and confirm injection before relying on this estimate.", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                }
            }
            if !calculation.exceedsTankCapacity && !calculation.exceedsDilutionCapacity {
                Section {
                    DisclosureGroup("Prepare your \(setup.tankSize.model)") {
                        PreparationSection(setup: setup, fertilizer: fertilizer)
                    }
                }
            }
            Section {
                DisclosureGroup("Feeding coverage") {
                    LabeledContent("Water until product is used up", value: "\(calculation.gallonsToEmpty.formatted(.number.precision(.fractionLength(0...2)))) gal")
                    if let minutes = calculation.runtimeMinutes {
                        LabeledContent("Estimated feeding time", value: "\(minutes) min")
                    } else {
                        Text("Check your flow rate to estimate feeding time.")
                    }
                }
            }
            Section {
                DisclosureGroup("Watering schedule and estimates") { ScheduleResultSection(calculation: calculation) }
            }
            GuidanceSection()
            Section {
                Button("View feeding chart", systemImage: "doc.text") { showingChart = true }
            }
        }
        .navigationTitle("Amount to add").navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingChart) { FeedingChartSheet() }
    }
}
