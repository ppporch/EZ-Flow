import SwiftUI

struct GuidanceSection: View {
    var body: some View {
        Section("Checks") {
            Text("Feed rates are approximate. Confirm feeding by color in the clear outlet tube while water is flowing; add dye if the product is clear. When the color runs out, the fertilizer is used up even though the tank remains full of water.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text("Recalculate the product amount whenever you change the feed setting, disc, or tank size. Changing the setting on an already filled tank changes the application rate.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
