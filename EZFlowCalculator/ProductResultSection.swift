import SwiftUI

struct ProductResultSection: View {
    let calculation: EZFlowCalculation

    var body: some View {
        Section("Product to Add") {
            Label {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(productSummary)
                        .font(.title2.bold())
                        .foregroundStyle(.primary)
                }
            } icon: {
                Image(systemName: "drop.fill")
                    .font(.title2)
                    .foregroundStyle(.tint)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(.tint.opacity(0.12), in: .rect(cornerRadius: 8))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Add \(productSummary)")

            Text("Top off with \(calculation.topOffWaterGallons.formatted(.number.precision(.fractionLength(1...2)))) gal water to reach the 2.0 gal liquid mix capacity.")
                .foregroundStyle(.secondary)

            LabeledContent("Product", value: "\(calculation.productTeaspoons.formatted(.number.precision(.fractionLength(0...1)))) tsp")
            LabeledContent("Tablespoons", value: "\(calculation.productTablespoons.formatted(.number.precision(.fractionLength(1...2)))) Tbsp")
            LabeledContent("Cups", value: "\(calculation.productCups.formatted(.number.precision(.fractionLength(2...2)))) cups")
            LabeledContent("Fluid ounces", value: "\(calculation.productFluidOunces.formatted(.number.precision(.fractionLength(1...2)))) fl oz")
        }
    }

    private var productSummary: String {
        if calculation.productCups < 1 {
            return "\(calculation.productFluidOunces.formatted(.number.precision(.fractionLength(1...2)))) fl oz"
        }

        if calculation.productGallons >= 0.25 {
            return "\(calculation.productGallons.formatted(.number.precision(.fractionLength(2...2)))) gal"
        }

        return "\(calculation.productCups.formatted(.number.precision(.fractionLength(1...2)))) cups"
    }
}
