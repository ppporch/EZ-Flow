import SwiftUI

struct ScheduleResultSection: View {
    let calculation: EZFlowCalculation

    var body: some View {
        Section("Schedule Estimate") {
            LabeledContent("Sessions / week", value: "\(calculation.sessionsPerWeek.formatted(.number.precision(.fractionLength(1...2))))")
            LabeledContent("Water / session", value: "\(calculation.gallonsPerSession.formatted(.number.precision(.fractionLength(0...1)))) gal")
            LabeledContent("Water / week", value: "\(calculation.gallonsPerWeek.formatted(.number.precision(.fractionLength(0...1)))) gal")
            LabeledContent("Product / session", value: productSessionText)
            LabeledContent("Product / week", value: productWeekText)
            LabeledContent("Full tank lasts", value: tankLifeText)
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
