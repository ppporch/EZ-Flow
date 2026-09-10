# EZ-Flow Calculator

A SwiftUI iPhone app for estimating fertilizer amounts for the ¾-gallon EZ 2005-HB and 2.5-gallon EZ 2020-HB hose and drip injectors.

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

## Calculations

```text
irrigation gallons until fertilizer is used up = selected tank capacity * ratio
product to add = irrigation gallons * product label rate per gallon
feeding runtime = irrigation gallons / irrigation flow rate
```

The default flow is 104 GPH, with White Flo-Disc, Fast, 2 tsp per 2 gallons, and a 30-minute session every 2 days. The 2.5-gallon tank calls for 62.5 tsp and feeds for about 36 minutes; the ¾-gallon tank calls for 18.75 tsp and feeds for about 11 minutes.

The fertilizer rate's **per 2 gal** option describes the product label's dilution rate, not a tank size.

Product needed per session/week assumes feeding at the entered rate throughout watering, with refills as needed. Coverage expresses average water use, not a calendar refill date. Sessions longer than one charge show a refill warning.

## Limits and preparation

The app suppresses filling instructions when calculated product volume exceeds the selected tank's nominal capacity. This is a gross capacity check, not a manufacturer-verified maximum product load. The feeding chart does not specify product-loading, dilution-space, or dry-product limits. Follow the unit's preparation instructions and product label. The calculator does not prescribe a top-off water quantity or validate powder displacement.

For a first application, the chart recommends half the label dose. Enter that reduced rate yourself; the calculator does not halve it automatically. Recalculate the product charge when changing the feed setting, disc, or tank size. Feed rates are approximate.

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
