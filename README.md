# EZ-Flow Calculator

A SwiftUI iPhone app for estimating fertilizer amounts for the ¾-gallon EZ 2005-HB and 2.5-gallon EZ 2020-HB hose and drip injectors.

## Support

Visit the [support page](https://ppporch.github.io/EZ-Flow/) for help, common questions, and contact information.

## Fertigator size and feeding reference

Choose **2.5 gallons** or **¾ gallon** in the Tank section. The default is 2.5 gallons. Changing size updates the product charge, feeding runtime, coverage, and nominal-capacity check.

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

This guidance comes from the [EZ-FLO Flo-Disc instructions](https://ezfloinjection.com/wp-content/uploads/2024/10/2021-Instructions-Flo-Disc-Web.pdf). The bundled feeding chart remains the source for dosage ratios.

## Saved setup and results

Tank size, flow, disc, feed setting, full label rate, first-application switch, and schedule are saved locally and restored on the next launch. New installations retain the existing defaults, with first-application dosing off.

Enter equipment and the fertilizer label rate, choose the feed setting, then read the product amount in a practical measuring unit: teaspoons below 3 tsp, tablespoons from 3 tsp to less than ¼ cup, and cups from ¼ cup upward. Fluid-ounce inputs keep fluid ounces as the primary result. The amount in the entered unit appears directly below when it differs, with other volume equivalents farther down. For example, the default charge shows **About 1.3 cups**, equivalent to **62.5 tsp**. Expand **Watering schedule and estimates** for optional session/week planning; these estimates use the selected full or half dose. No account or internet connection is required.

## Calculations

```text
irrigation gallons until fertilizer is used up = selected tank capacity * ratio
effective rate = product label rate per gallon * (0.5 for first application, otherwise 1)
product to add = irrigation gallons * effective rate
feeding runtime = irrigation gallons / irrigation flow rate
```

The default flow is 104 GPH, with White Flo-Disc, Fast, 2 tsp per 2 gallons, and a 30-minute session every 2 days. The 2.5-gallon tank calls for 62.5 tsp and feeds for about 36 minutes; the ¾-gallon tank calls for 18.75 tsp and feeds for about 11 minutes.

The fertilizer rate's **per 2 gal** option describes the product label's dilution rate, not a tank size.

Product needed per session/week assumes feeding at the entered rate throughout watering, with refills as needed. Coverage expresses average water use, not a calendar refill date. Sessions longer than one charge show a refill warning.

## Limits and preparation

The app suppresses filling instructions when calculated product volume exceeds the selected tank's nominal capacity. This is a gross capacity check, not a manufacturer-verified maximum product load. The feeding chart does not specify product-loading, dilution-space, or dry-product limits. Follow the unit's preparation instructions and product label. The calculator does not prescribe a top-off water quantity or validate powder displacement.

For a first application, the chart recommends half the label dose. Enter the full label rate and enable **First application: 50% of label rate**. The app preserves the entered label rate, shows the effective rate, and applies the reduction once to the tank charge and session/week product estimates. Feeding runtime and water coverage do not change. The switch is remembered; turn it off for later applications at the full label rate. Recalculate the product charge when changing the feed setting, disc, or tank size. Feed rates are approximate.

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

Tests cover both tank sizes and all settings/discs, conversions, schedules, nominal-capacity checks, extreme runtime input, and loading both pages of the bundled PDF.
