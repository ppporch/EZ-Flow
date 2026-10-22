import SwiftUI

struct FertilizerFields: View {
    @Binding var fertilizer: FertilizerProfile

    var body: some View {
        Section("Product") {
            TextField("Fertilizer name", text: $fertilizer.name).accessibilityIdentifier("fertilizerName")
            Picker("Product type", selection: $fertilizer.kind) {
                ForEach(FertilizerKind.allCases) { kind in Text(kind.title).tag(kind) }
            }
        }
        Section("Full rate from the label") {
            DecimalInput(title: "Label amount", value: $fertilizer.amount)
            Picker("Measuring unit", selection: $fertilizer.unit) {
                ForEach(FertilizerRateUnit.allCases) { unit in Text(unit.displayName).tag(unit) }
            }
            Picker("Label water volume", selection: $fertilizer.basis) {
                ForEach(FertilizerRateBasis.allCases) { basis in Text(basis.displayName).tag(basis) }
            }
            Text("Enter the full rate for ordinary watering, before injector concentration. For example, 2 teaspoons per 2 gallons. The water volume is from the label, not the tank size.")
                .font(.footnote).foregroundStyle(.secondary)
            if !fertilizer.amount.isFinite || fertilizer.amount <= 0 {
                Text("Enter a label amount greater than zero to continue.").font(.footnote).foregroundStyle(.orange)
            }
            if fertilizer.kind == .solublePowder {
                Text("Use water-soluble powder with a label rate in teaspoons, tablespoons, or cups. Fluid ounces measure liquid volume. Grams, ounces by weight, and pounds cannot be converted without product-specific information; do not substitute a weight rate.")
                    .font(.footnote).foregroundStyle(.secondary)
                if fertilizer.unit == .fluidOunce {
                    Label("For powder, choose a spoon or cup volume from the label. Fluid ounces apply to liquid products.", systemImage: "exclamationmark.triangle")
                        .font(.footnote).foregroundStyle(.orange)
                }
            }
        }
    }
}
