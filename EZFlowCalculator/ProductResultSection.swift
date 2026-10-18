import SwiftUI

struct ProductResultSection: View {
    let calculation: EZFlowCalculation

    var body: some View {
        Section("Product to Add") {
            if calculation.exceedsTankCapacity {
                Label("The calculated amount exceeds the selected tank's \(calculation.tankSize.gallons.formatted()) gal capacity. Do not fill using this amount. Select a faster feed setting and recalculate, or verify a suitable application plan.", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            } else {
                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Add")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("About \(productSummary)")
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                        if calculation.preferredProductUnit != calculation.fertilizerUnit {
                            Text("Equivalent to \(calculation.productInLabelUnitsSummary)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
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

                Text("Prepare and fill according to your unit's instructions and the product label. The feeding chart calculates dosage; it does not specify product-loading or dilution limits.")
                    .foregroundStyle(.secondary)
            }

            if calculation.isFirstApplication {
                Label("First application: amounts use 50% of your entered label rate.", systemImage: "leaf")
                    .font(.footnote)
            }
            LabeledContent("Teaspoons", value: "\(calculation.productTeaspoons.formatted(.number.precision(.fractionLength(0...1)))) tsp")
            LabeledContent("Tablespoons", value: "\(calculation.productTablespoons.formatted(.number.precision(.fractionLength(1...2)))) Tbsp")
            LabeledContent("Cups", value: "\(calculation.productCups.formatted(.number.precision(.fractionLength(2...2)))) cups")
            if calculation.fertilizerUnit == .fluidOunce {
                LabeledContent("Fluid ounces", value: "\(calculation.productFluidOunces.formatted(.number.precision(.fractionLength(1...2)))) fl oz")
            }
            Text("Amounts use liquid-volume equivalents. This calculator does not check dry-product weight, powder displacement, or required dilution space.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var productSummary: String {
        calculation.productSummary
    }
}
