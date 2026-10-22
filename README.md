# EZ-Flow Calculator

A SwiftUI iPhone app for estimating fertilizer amounts for the ¾-gallon EZ 2005-HB and 2.5-gallon EZ 2020-HB hose and drip injectors.

## Support

Visit the [support page](https://ppporch.github.io/EZ-Flow/) for help, common questions, and contact information.

## Fertigator size and feeding reference

Choose **2.5 gallons** or **¾ gallon** in the installed-equipment section of a named setup. Changing size updates the product charge, feeding runtime, coverage, and capacity checks.

The app uses only the [2022 hose bib feeding chart from Drip Depot](https://www.dripdepot.com/file/parent/1205/1205-2022%20Hose%20Bib%20Feed%20Chart%20Instructions%20v1.pdf). The supplied PDF is included in the app bundle. Tap **View feeding chart** to open both pages in a sheet with scrolling, pinch-to-zoom, and a Done button. No internet connection is needed.

| Setting | Ratio, no disc | Ratio, any disc | 2.5 gal, no disc / disc | ¾ gal, no disc / disc |
| --- | ---: | ---: | ---: | ---: |
| Slow | 1000:1 | 250:1 | 2500 / 625 gal | 750 / 187.5 gal |
| 1 | 500:1 | 125:1 | 1250 / 312.5 gal | 375 / 93.75 gal |
| 2 | 250:1 | 62.5:1 | 625 / 156.25 gal | 187.5 / 46.875 gal |
| Fast | 100:1 | 25:1 | 250 / 62.5 gal | 75 / 18.75 gal |

The last two columns show irrigation gallons until fertilizer is used up. Values preserve exact capacity × ratio instead of printed rounding. The chart's ¾-gallon disc row for setting 2 prints 50, but 62.5 × 0.75 is 46.875; the app uses the exact calculation.

## Flo-Disc flow guidance

With **No Disc** selected, flows below 120 GPH show an orange message that a Flo-Disc may be needed, with a reminder to check the disc ranges and confirm injection by color in the clear outlet tube. At 120 GPH and above, the message confirms the minimum-flow guideline is met; it does not imply an upper operating limit or guarantee injection. Invalid or zero flow prompts for a positive flow value.

This guidance comes from the [EZ-FLO Flo-Disc instructions](https://ezfloinjection.com/wp-content/uploads/2021-Instructions-Flo-Disc-Web.pdf). The bundled feeding chart remains the source for dosage ratios. The app suggests a disc for the entered flow but continues using the installed selection until the user updates it. At shared boundaries (30, 60, and 120 GPH), an installed disc within its published range does not prompt a change. Flows below 7.5 GPH have no recommendation.

## Setups, fertilizers, and results

Save a named setup for each installed injector. Each remembers tank size, installed disc, feed setting, flow method and configuration, selected fertilizer, first-feeding switch, and optional watering schedule. With one location the app opens it directly on launch; with multiple locations it opens the selection list. Complete locations open a short **Saved settings** summary. **Use these settings** confirms the displayed label rate and immediately shows the amount to add, without a second confirmation screen. **Change settings** opens the full editor; returning to the summary shows the saved edits and the latest shared fertilizer rate. New or incomplete locations open the full editor and stay there while their fields are being completed. The back button returns to the location list to add or delete setups; names can be changed in the editor. Equipment and flow edits save automatically. New setups require a positive flow before calculation. Existing personal app settings are imported once as **My drip system** and **My fertilizer** when present.

Fertilizer profiles are shared across setups. Save the product's name, liquid or water-soluble powder type, and full label mixing rate. Returning users confirm the rate directly on the quick summary. In the full editor, **Review rate & calculate** lets the user confirm or edit it; **Confirm rate & calculate** saves the rate to the shared profile and opens the result. Canceling leaves the saved profile unchanged. Deleting a fertilizer clears its selection from linked setups without deleting their equipment. The quick path captures the accepted settings and rate so an open result stays consistent.

Results combine familiar US cup and spoon fractions, rounded to the nearest **⅛ teaspoon** (at most **1/16 teaspoon** rounding error), and show the decimal label-unit equivalent. For example, 62.5 tsp becomes **1¼ cups + 2½ tsp**. Amounts below 1/16 tsp display **Less than ⅛ tsp**. Fluid ounces remain available as an equivalent for liquid products. Weight-based label rates are not supported; fluid ounces must not be substituted for ounces by weight.

The result puts the fertilizer amount first. Preparation instructions, settings used, measurement equivalents, feeding coverage, and watering estimates are collapsed until needed. No account or internet connection is required for saved setups, calculations, preparation steps, or the bundled feeding chart.

## Drip-system flow helper

Enter a known total in GPH, or select **Calculate from drippers & lines**. Save groups with different emitter ratings:

- **Individual drippers:** count × flow per emitter in GPH.
- **Drip line:** combined length in feet × 12 ÷ emitter spacing in inches × flow per emitter in GPH.

All groups in a setup are assumed to run simultaneously. The line calculation estimates emitter count without rounding; actual count can differ at cut ends. Use a dripper group for an exact known count. Switching between direct flow and the helper preserves both entries, but only the selected method contributes to flow. Groups can be edited or deleted as the installation changes.

## Calculations

```text
irrigation gallons until fertilizer is used up = selected tank capacity * ratio
effective rate = product label rate per gallon * (0.5 for first feeding of season, otherwise 1)
product to add = irrigation gallons * effective rate
feeding runtime = irrigation gallons / irrigation flow rate
```

Example: at 104 GPH, with White Flo-Disc, Fast, and 2 tsp per 2 gallons, the 2.5-gallon tank calls for 62.5 tsp and feeds for about 36 minutes; the ¾-gallon tank calls for 18.75 tsp and feeds for about 11 minutes.

The fertilizer rate's **per 2 gal** option describes the product label's dilution rate, not a tank size.

Product needed per session/week assumes feeding at the entered rate throughout watering, with refills as needed. Coverage expresses average water use, not a calendar refill date. Sessions longer than one charge show a refill warning.

## Limits and preparation

The app suppresses the measurement callout and filling instructions when calculated product volume exceeds the tank's nominal capacity, or when the Flo-Disc's 3-parts-water-to-1-part-product pre-dilution would exceed it using volume equivalents. These checks cannot verify dry-product weight, powder displacement, solubility, or a product-specific loading limit.

Offline preparation steps cover shutting off water and releasing pressure, emptying old tank water, measuring liquid or soluble powder, pre-dilution with a Flo-Disc, topping off to the final tank volume, reconnecting the labeled fittings, and checking injection by color. They are adapted from the manufacturer's [EZ 2020-HB guide](https://ezfloinjection.com/wp-content/uploads/2024-Instructions-2020HB-Web-v1-1.pdf), [EZ 2005-HB guide](https://ezfloinjection.com/wp-content/uploads/2024-Instructions-2005HB-Web-v1.pdf), and Flo-Disc instructions. Source links are also included in the app. Follow the product label's preparation instructions; only fully water-soluble, injection-compatible powder products are appropriate. The app does not convert volume to dry weight or calculate an exact top-off water quantity.

The feeding chart recommends half the label dose for an initial application. The app exposes this as **First feeding of the season**, controlled by the user and remembered separately for each setup. Enter the full label rate; the app applies the reduction once to the tank charge and session/week product estimates. Feeding runtime and water coverage do not change. Turn the switch off for subsequent feedings. Recalculate the product charge when changing the feed setting, disc, or tank size. Feed rates are approximate.

## Build and test

Open `EZFlowCalculator.xcodeproj` in Xcode, or select an installed simulator:

```bash
xcodebuild -showdestinations -project EZFlowCalculator.xcodeproj -scheme EZFlowCalculator

xcodebuild test \
  -project EZFlowCalculator.xcodeproj \
  -scheme EZFlowCalculator \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' \
  -derivedDataPath /private/tmp/EZFlowCalculatorDerivedData
```

Tests cover both tank sizes and all settings/discs, mixed emitter and line groups, unit conversion, fractional measurements and rounding boundaries, schedules, nominal and dilution-capacity checks, invalid/extreme input, shared-rate changes, setup/profile persistence, deletion links, preserving unreadable saved data, importing existing personal settings, and loading both pages of the bundled PDF.
