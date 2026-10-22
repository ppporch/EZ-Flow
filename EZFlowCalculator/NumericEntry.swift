import Foundation

enum NumericEntry {
    // Foundation's number parser accepts a numeric prefix ("1/2" becomes 1).
    // Reject other characters before parsing so pasted label text cannot change a dose silently.
    static func decimal(_ text: String, locale: Locale = .current) -> Double? {
        guard isNumeric(text, locale: locale, allowsDecimal: true),
              let value = try? Double(text, format: .number.locale(locale), lenient: false),
              value.isFinite else { return nil }
        return value
    }

    static func integer(_ text: String, locale: Locale = .current) -> Int? {
        guard isNumeric(text, locale: locale, allowsDecimal: false) else { return nil }
        return try? Int(text, format: .number.locale(locale), lenient: false)
    }

    private static func isNumeric(_ text: String, locale: Locale, allowsDecimal: Bool) -> Bool {
        var number = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if number.first == "+" || number.first == "-" { number.removeFirst() }
        guard !number.isEmpty else { return false }
        let decimal = locale.decimalSeparator ?? "."
        let grouping = locale.groupingSeparator ?? ","
        let parts = allowsDecimal ? number.components(separatedBy: decimal) : [number]
        guard parts.count <= 2 else { return false }
        let integerGroups = parts[0].components(separatedBy: grouping)
        if integerGroups.count > 1 {
            guard (1...3).contains(integerGroups[0].count),
                  integerGroups.dropFirst().allSatisfy({ $0.count == 3 }) else { return false }
        }
        let integerDigits = integerGroups.joined()
        let fractionalDigits = parts.count == 2 ? parts[1] : ""
        let digits = integerDigits + fractionalDigits
        return !digits.isEmpty && digits.unicodeScalars.allSatisfy { CharacterSet.decimalDigits.contains($0) }
    }
}
