# EZ-Flow Calculator

EZ-Flow Calculator is a small SwiftUI iPhone app for estimating how much fertilizer product to add to an EZ-FLO EZ 2020-HB hose and drip fertilizer injector.

The app is tuned for this setup:

- EZ 2020-HB 2.5 gallon tank
- 2.0 gallons usable liquid mix capacity
- White Flo-Disc default
- 104 gallons per hour default irrigation flow

## What It Calculates

The app lets you enter:

- Irrigation flow rate in gallons per hour
- Flo-Disc selection
- Fertilizer label rate, either per gallon or per 2 gallons
- Watering interval, from every day through every 14 days
- Minutes per watering session
- EZ-FLO feed setting: Slow, 1, 2, or Fast

It calculates:

- Injection ratio
- Gallons of irrigation water until the tank mix is depleted
- Runtime until empty
- Product amount to add in teaspoons, tablespoons, cups, and fluid ounces
- Water needed to top off the tank mix to 2 gallons
- Water and product estimates per session and per week
- Approximate sessions and weeks before the tank mix is empty

## EZ-FLO Assumptions

The app uses the EZ 2020-HB manual feed ratios.

Without a Flo-Disc:

| Setting | Ratio |
| --- | ---: |
| Slow | 1000:1 |
| 1 | 500:1 |
| 2 | 250:1 |
| Fast | 100:1 |

With any Flo-Disc:

| Setting | Ratio |
| --- | ---: |
| Slow | 250:1 |
| 1 | 125:1 |
| 2 | 62.5:1 |
| Fast | 25:1 |

For a 2 gallon usable liquid mix capacity:

```text
gallons to empty = 2.0 * injection ratio
```

## Build And Test

Open `EZFlowCalculator.xcodeproj` in Xcode, or build from Terminal:

```bash
xcodebuild test \
  -project EZFlowCalculator.xcodeproj \
  -scheme EZFlowCalculator \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
  -derivedDataPath /private/tmp/EZFlowCalculatorDerivedData
```

## Notes

All feed rates are approximate. Product viscosity, water pressure, irrigation layout, and actual flow rate can change real-world results. Follow the fertilizer product label and start conservatively when applying a new product.
