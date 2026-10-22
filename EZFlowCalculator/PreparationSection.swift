import SwiftUI

struct PreparationSection: View {
    let setup: IrrigationSetup
    let fertilizer: FertilizerProfile

    var body: some View {
        Group {
            Text("1. Turn off the water and release pressure before opening the tank or disconnecting tubing. When refilling, empty the old tank water before adding a new charge.")
            if fertilizer.kind == .solublePowder {
                Text("2. Measure the water-soluble powder shown above with dedicated measuring tools. Use only injection-compatible, fully water-soluble products, not dry broadcast granules. Follow the product label's mixing directions; the app cannot convert powder volume to weight or check its dry-weight loading limit.")
            } else {
                Text("2. Measure the liquid fertilizer shown above with dedicated measuring tools. Follow the product label's mixing directions.")
            }
            if setup.disc.hasDisc {
                Text("3. With a Flo-Disc, EZ-FLO calls for pre-dilution with 3 parts water to 1 part product (25% strength). Include that water when preparing the charge. For powder, follow its dissolution directions as well. Do not try to fit a mixture that exceeds the tank capacity.")
            } else {
                Text("3. Add the measured product to the tank. The injector mixes compatible products as water runs; premix if the product label requires it.")
            }
            Text("4. Top off the tank with water until air is displaced, following your unit's filling instructions. The tank size is the final filled volume, not an extra quantity of water to add.")
            Text("5. Secure the cap, reconnect the inlet and outlet tubing to their matching labeled fittings, and set the cap to \(setup.feedSetting.displayName). Restore water flow and confirm fertilizer color in the clear outlet tube; add food dye if the product is clear.")
            Text("When the color runs out, the fertilizer charge is used up even though the tank stays full of water. Recalculate before filling again if the equipment or label rate changes.")
                .font(.footnote).foregroundStyle(.secondary)
            DisclosureGroup("Instruction sources") {
                Text("Adapted from EZ-FLO's hose-bib injector operating guides (filling/refilling, pages 5–7) and Flo-Disc instructions. The steps above are available offline.")
                if let url = URL(string: setup.tankSize == .twoAndHalfGallons
                                 ? "https://ezfloinjection.com/wp-content/uploads/2024-Instructions-2020HB-Web-v1-1.pdf"
                                 : "https://ezfloinjection.com/wp-content/uploads/2024-Instructions-2005HB-Web-v1.pdf") {
                    Link("Manufacturer's \(setup.tankSize.model) guide", destination: url)
                }
                if let url = URL(string: "https://ezfloinjection.com/wp-content/uploads/2021-Instructions-Flo-Disc-Web.pdf") {
                    Link("Manufacturer's Flo-Disc instructions", destination: url)
                }
            }
            .font(.footnote)
        }
    }
}
