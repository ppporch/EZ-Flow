import SwiftUI

struct DecimalInput: View {
    @Environment(\.locale) private var locale
    let title: LocalizedStringKey
    @Binding var value: Double
    @State private var text: String
    @FocusState private var isFocused: Bool

    init(title: LocalizedStringKey, value: Binding<Double>) {
        self.title = title
        _value = value
        _text = State(initialValue: value.wrappedValue.formatted(.number.grouping(.never).precision(.significantDigits(1...15))))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            LabeledContent(title) {
                TextField(title, text: $text)
                    .multilineTextAlignment(.trailing).keyboardType(.decimalPad).accessibilityLabel(title)
                    .focused($isFocused)
            }
            if !text.isEmpty && NumericEntry.decimal(text, locale: locale) == nil {
                Text("Enter a decimal number, such as 0.5. Do not include units or fractions.")
                    .font(.caption).foregroundStyle(.red)
            }
        }
        .onChange(of: text) {
            value = NumericEntry.decimal(text, locale: locale) ?? 0
        }
        .onChange(of: value) {
            if !isFocused { text = value.formatted(.number.grouping(.never).precision(.significantDigits(1...15)).locale(locale)) }
        }
    }
}
