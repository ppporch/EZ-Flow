import SwiftUI

struct ScheduleResultSection: View {
    let calculation: EZFlowCalculation

    var body: some View {
        Section("Schedule Estimate") {
            LabeledContent("Sessions / week", value: "\(calculation.sessionsPerWeek.formatted(.number.precision(.fractionLength(1...2))))")
            LabeledContent("Water / session", value: "\(calculation.gallonsPerSession.formatted(.number.precision(.fractionLength(0...1)))) gal")
            LabeledContent("Water / week", value: "\(calculation.gallonsPerWeek.formatted(.number.precision(.fractionLength(0...1)))) gal")
            LabeledContent("Product needed / session", value: productSessionText)
            LabeledContent("Product needed / week", value: productWeekText)
            LabeledContent("One fertilizer charge covers", value: tankLifeText)
            Text("Product needs assume feeding at the entered rate throughout watering, with refills as needed. Coverage is an average based on water use, not a calendar refill date.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            if calculation.sessionsToEmpty > 0 && calculation.sessionsToEmpty < 1 {
                Label("One charge will be used up before this watering session ends. A refill is needed to feed for the entire session; shut off pressure before refilling.", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
            }
        }
    }

    private var productSessionText: String {
        if calculation.productFluidOuncesPerSession >= 1 {
            return "\(calculation.productFluidOuncesPerSession.formatted(.number.precision(.fractionLength(1...2)))) fl oz"
        }

        return "\(calculation.productTeaspoonsPerSession.formatted(.number.precision(.fractionLength(1...2)))) tsp"
    }

    private var productWeekText: String {
        if calculation.productFluidOuncesPerWeek >= 1 {
            return "\(calculation.productFluidOuncesPerWeek.formatted(.number.precision(.fractionLength(1...2)))) fl oz"
        }

        return "\(calculation.productTeaspoonsPerWeek.formatted(.number.precision(.fractionLength(1...2)))) tsp"
    }

    private var tankLifeText: String {
        guard calculation.sessionsToEmpty > 0 else { return "Enter schedule" }

        if calculation.weeksToEmpty > 0 {
            return "\(calculation.sessionsToEmpty.formatted(.number.precision(.fractionLength(1...1)))) sessions / \(calculation.weeksToEmpty.formatted(.number.precision(.fractionLength(1...1)))) weeks"
        }

        return "\(calculation.sessionsToEmpty.formatted(.number.precision(.fractionLength(1...1)))) sessions"
    }
}
