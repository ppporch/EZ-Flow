import SwiftUI

struct ProductResultSection: View {
    let calculation: EZFlowCalculation

    var body: some View {
        Section("Product to Add") {
            if calculation.exceedsTankCapacity {
                Label("The calculated amount exceeds the selected tank's \(calculation.tankSize.gallons.formatted()) gal capacity. Do not fill using this amount. Select a faster feed setting and recalculate, or verify a suitable application plan.", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            } else if calculation.exceedsDilutionCapacity {
                Label("This amount would not leave room for the Flo-Disc's 3-parts-water-to-1-part-product pre-dilution using volume equivalents. Do not fill using this amount. Choose a faster feed setting and recalculate, or check a suitable plan with the manufacturer.", systemImage: "exclamationmark.triangle.fill")
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
                        Text("Label-unit equivalent: \(calculation.productInLabelUnitsSummary)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
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

                Text("Cup-and-spoon amounts are rounded to the nearest ⅛ teaspoon. Use US measuring cups and spoons, dedicated to fertilizer. Follow the preparation steps below.")
                    .font(.footnote).foregroundStyle(.secondary)
            }

            if calculation.isFirstApplication {
                Label("First feeding of the season: amounts use 50% of your entered label rate.", systemImage: "leaf")
                    .font(.footnote)
            }
            DisclosureGroup("Measurement equivalents and limits") {
                LabeledContent("Teaspoons", value: "\(calculation.productTeaspoons.formatted(.number.precision(.fractionLength(0...1)))) tsp")
                LabeledContent("Tablespoons", value: "\(calculation.productTablespoons.formatted(.number.precision(.fractionLength(1...2)))) Tbsp")
                LabeledContent("Cups", value: "\(calculation.productCups.formatted(.number.precision(.fractionLength(2...2)))) cups")
                if calculation.fertilizerUnit == .fluidOunce {
                    LabeledContent("Fluid ounces", value: "\(calculation.productFluidOunces.formatted(.number.precision(.fractionLength(1...2)))) fl oz")
                }
                Text("The dilution check uses volume equivalents. It cannot verify dry-product weight, powder displacement, solubility, or product-specific mixing limits.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var productSummary: String {
        calculation.productSummary
    }
}
