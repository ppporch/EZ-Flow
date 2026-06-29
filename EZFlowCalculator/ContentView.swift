import SwiftUI

struct ContentView: View {
    private enum FocusedField {
        case flowRate
        case fertilizerAmount
        case minutesPerSession
    }

    @State private var flowRateText = "104"
    @State private var selectedDisc: FlowDisc = .white
    @State private var selectedSetting: FeedSetting = .fast
    @State private var fertilizerAmountText = "2"
    @State private var fertilizerUnit: FertilizerRateUnit = .teaspoon
    @State private var fertilizerRateBasis: FertilizerRateBasis = .perTwoGallons
    @State private var wateringIntervalDays = 2
    @State private var minutesPerSessionText = "30"
    @FocusState private var focusedField: FocusedField?

    private let presets: [FertilizerPreset] = [
        FertilizerPreset(title: "2 tsp/2 gal", amount: 2, unit: .teaspoon, basis: .perTwoGallons),
        FertilizerPreset(title: "2 Tbsp/2 gal", amount: 2, unit: .tablespoon, basis: .perTwoGallons),
        FertilizerPreset(title: "4 Tbsp/2 gal", amount: 4, unit: .tablespoon, basis: .perTwoGallons),
        FertilizerPreset(title: "2 fl oz/2 gal", amount: 2, unit: .fluidOunce, basis: .perTwoGallons)
    ]

    private var flowRate: Double {
        Double(flowRateText) ?? 0
    }

    private var fertilizerAmount: Double {
        Double(fertilizerAmountText) ?? 0
    }

    private var minutesPerSession: Double {
        Double(minutesPerSessionText) ?? 0
    }

    private var calculation: EZFlowCalculation {
        EZFlowCalculation(
            flowRateGPH: flowRate,
            feedSetting: selectedSetting,
            flowDisc: selectedDisc,
            fertilizerAmount: fertilizerAmount,
            fertilizerUnit: fertilizerUnit,
            fertilizerRateBasis: fertilizerRateBasis,
            wateringIntervalDays: Double(wateringIntervalDays),
            minutesPerSession: minutesPerSession
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                tankSection
                irrigationSection
                scheduleSection
                fertilizerSection
                settingSection
                resultSection
                scheduleResultSection
                guidanceSection
            }
            .navigationTitle("EZ-Flow Calculator")
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
    }

    private var tankSection: some View {
        Section("Tank") {
            LabeledContent("Model", value: "EZ 2020-HB")
            LabeledContent("Tank size", value: "2.5 gal")
            LabeledContent("Usable liquid mix", value: "2.0 gal")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
    }

    private var irrigationSection: some View {
        Section("Irrigation") {
            HStack {
                Text("Flow rate")
                Spacer()
                TextField("104", text: $flowRateText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .focused($focusedField, equals: .flowRate)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
                    .frame(maxWidth: 90)
                Text("GPH")
                    .foregroundStyle(.secondary)
            }

            Picker("Flo-Disc", selection: $selectedDisc) {
                ForEach(FlowDisc.allCases) { disc in
                    Text(disc.rawValue).tag(disc)
                }
            }
            .onChange(of: selectedDisc) {
                focusedField = nil
            }

            Text(selectedDisc.flowMessage(for: flowRate))
                .font(.footnote)
                .foregroundStyle(flowDiscMessageColor)
        }
    }

    private var fertilizerSection: some View {
        Section("Fertilizer Rate") {
            HStack {
                TextField("Amount", text: $fertilizerAmountText)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .fertilizerAmount)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
                Picker("Unit", selection: $fertilizerUnit) {
                    ForEach(FertilizerRateUnit.allCases) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .labelsHidden()
                .onChange(of: fertilizerUnit) {
                    focusedField = nil
                }
                Picker("Basis", selection: $fertilizerRateBasis) {
                    ForEach(FertilizerRateBasis.allCases) { basis in
                        Text(basis.rawValue).tag(basis)
                    }
                }
                .labelsHidden()
                .onChange(of: fertilizerRateBasis) {
                    focusedField = nil
                }
            }

            LabeledContent("Normalized rate", value: "\(calculation.fertilizerTeaspoonsPerGallon.formatted(.number.precision(.fractionLength(1...2)))) tsp/gal")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(presets) { preset in
                        Button(preset.title) {
                            focusedField = nil
                            fertilizerAmountText = preset.amount.formatted(.number.precision(.fractionLength(0...2)))
                            fertilizerUnit = preset.unit
                            fertilizerRateBasis = preset.basis
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var scheduleSection: some View {
        Section("Watering Schedule") {
            Picker("Watering interval", selection: $wateringIntervalDays) {
                ForEach(1...14, id: \.self) { days in
                    Text(wateringIntervalLabel(for: days)).tag(days)
                }
            }
            .onChange(of: wateringIntervalDays) {
                focusedField = nil
            }

            HStack {
                Text("Minutes / session")
                Spacer()
                TextField("30", text: $minutesPerSessionText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .focused($focusedField, equals: .minutesPerSession)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
                    .frame(maxWidth: 80)
            }
        }
    }

    private var settingSection: some View {
        Section("EZ-Flow Setting") {
            Picker("Feed rate", selection: $selectedSetting) {
                ForEach(FeedSetting.allCases) { setting in
                    Text(setting.rawValue).tag(setting)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedSetting) {
                focusedField = nil
            }

            LabeledContent("Injection ratio", value: "\(calculation.ratio.formatted(.number.precision(.fractionLength(0...1)))):1")
            LabeledContent("Gallons to empty", value: "\(calculation.gallonsToEmpty.formatted(.number.precision(.fractionLength(0...1)))) gal")
            LabeledContent("Runtime", value: runtimeText)
        }
    }

    private var resultSection: some View {
        Section("Product to Add") {
            VStack(alignment: .leading, spacing: 8) {
                Text(productSummary)
                    .font(.title2.bold())
                Text("Top off with \(calculation.topOffWaterGallons.formatted(.number.precision(.fractionLength(1...2)))) gal water to reach the 2.0 gal liquid mix capacity.")
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)

            LabeledContent("Product", value: "\(calculation.productTeaspoons.formatted(.number.precision(.fractionLength(0...1)))) tsp")
            LabeledContent("Tablespoons", value: "\(calculation.productTablespoons.formatted(.number.precision(.fractionLength(1...2)))) Tbsp")
            LabeledContent("Cups", value: "\(calculation.productCups.formatted(.number.precision(.fractionLength(2...2)))) cups")
            LabeledContent("Fluid ounces", value: "\(calculation.productFluidOunces.formatted(.number.precision(.fractionLength(1...2)))) fl oz")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
    }

    private var scheduleResultSection: some View {
        Section("Schedule Estimate") {
            LabeledContent("Sessions / week", value: "\(calculation.sessionsPerWeek.formatted(.number.precision(.fractionLength(1...2))))")
            LabeledContent("Water / session", value: "\(calculation.gallonsPerSession.formatted(.number.precision(.fractionLength(0...1)))) gal")
            LabeledContent("Water / week", value: "\(calculation.gallonsPerWeek.formatted(.number.precision(.fractionLength(0...1)))) gal")
            LabeledContent("Product / session", value: productSessionText)
            LabeledContent("Product / week", value: productWeekText)
            LabeledContent("Full tank lasts", value: tankLifeText)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
    }

    private var guidanceSection: some View {
        Section("Checks") {
            if calculation.exceedsTankCapacity {
                Label("This application rate requires more than 2 gallons of product. Use a stronger EZ-Flow setting or split the application.", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            }

            if calculation.exceedsFloDiscPremixGuidance {
                Label("With a Flo-Disc, the manual recommends a 25% product mix. This result is above that guidance.", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            } else if selectedDisc.hasDisc {
                Label("Flo-Disc setup: add product, then water to make 2.0 gallons total mix.", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }

            Text("First application: EZ-FLO recommends starting at half of the fertilizer label rate.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
    }

    private var flowDiscMessageColor: Color {
        guard let range = selectedDisc.flowRange else { return .secondary }
        return range.contains(flowRate) ? .green : .orange
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

    private var runtimeText: String {
        let totalMinutes = Int((calculation.runtimeHours * 60).rounded())
        guard totalMinutes > 0 else { return "Enter flow" }

        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours == 0 {
            return "\(minutes) min"
        }

        if minutes == 0 {
            return "\(hours) hr"
        }

        return "\(hours) hr \(minutes) min"
    }

    private var productSessionText: String {
        if calculation.productFluidOuncesPerSession >= 1 {
            return "\(calculation.productFluidOuncesPerSession.formatted(.number.precision(.fractionLength(1...2)))) fl oz"
        }

        return "\(calculation.productTeaspoonsPerSession.formatted(.number.precision(.fractionLength(1...2)))) tsp"
    }

    private var productWeekText: String {
        if calculation.productFluidOuncesPerWeek >= 1 {
            return "\(calculation.productFluidOuncesPerWeek.formatted(.number.precision(.fractionLength(1...2)))) fl oz"
        }

        return "\(calculation.productTeaspoonsPerWeek.formatted(.number.precision(.fractionLength(1...2)))) tsp"
    }

    private var tankLifeText: String {
        guard calculation.sessionsToEmpty > 0 else { return "Enter schedule" }

        if calculation.weeksToEmpty > 0 {
            return "\(calculation.sessionsToEmpty.formatted(.number.precision(.fractionLength(1...1)))) sessions / \(calculation.weeksToEmpty.formatted(.number.precision(.fractionLength(1...1)))) weeks"
        }

        return "\(calculation.sessionsToEmpty.formatted(.number.precision(.fractionLength(1...1)))) sessions"
    }

    private func wateringIntervalLabel(for days: Int) -> String {
        if days == 1 {
            return "Every day"
        }

        return "Every \(days) days"
    }
}

#Preview {
    ContentView()
}
