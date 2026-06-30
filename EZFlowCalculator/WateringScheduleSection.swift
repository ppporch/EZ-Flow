import SwiftUI

struct WateringScheduleSection: View {
    @Binding var wateringIntervalDays: Int
    @Binding var minutesPerSession: Double
    let focusedField: FocusState<FocusedField?>.Binding

    var body: some View {
        Section("Watering Schedule") {
            Picker("Watering interval", selection: $wateringIntervalDays) {
                ForEach(1...14, id: \.self) { days in
                    Text(wateringIntervalLabel(for: days)).tag(days)
                }
            }
            .onChange(of: wateringIntervalDays, dismissKeyboard)

            HStack {
                Text("Minutes / session")
                Spacer()
                TextField("30", value: $minutesPerSession, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .focused(focusedField, equals: .minutesPerSession)
                    .submitLabel(.done)
                    .onSubmit(dismissKeyboard)
                    .frame(maxWidth: 80)
            }
        }
    }

    private func dismissKeyboard() {
        focusedField.wrappedValue = nil
    }

    private func wateringIntervalLabel(for days: Int) -> String {
        if days == 1 {
            "Every day"
        } else {
            "Every \(days) days"
        }
    }
}
