import SwiftUI

struct IntegerInput: View {
    @Environment(\.locale) private var locale
    let title: LocalizedStringKey
    @Binding var value: Int
    @State private var text: String

    init(title: LocalizedStringKey, value: Binding<Int>) {
        self.title = title
        _value = value
        _text = State(initialValue: value.wrappedValue.formatted(.number.grouping(.never)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            LabeledContent(title) {
                TextField(title, text: $text).keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing).accessibilityLabel(title)
            }
            if !text.isEmpty && NumericEntry.integer(text, locale: locale) == nil {
                Text("Enter a whole number of drippers.").font(.caption).foregroundStyle(.red)
            }
        }
        .onChange(of: text) { value = NumericEntry.integer(text, locale: locale) ?? 0 }
    }
}
