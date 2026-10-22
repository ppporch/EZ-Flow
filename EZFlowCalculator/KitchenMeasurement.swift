import Foundation

enum KitchenMeasurement {
    /// Nearest 1/8 teaspoon; the error is at most 1/16 teaspoon.
    static func summary(teaspoons: Double) -> String {
        guard teaspoons.isFinite, teaspoons >= 0, teaspoons < Double(Int.max / 16) else { return "Check amount" }
        if teaspoons == 0 { return "0 tsp" }
        if teaspoons < 0.0625 { return "Less than ⅛ tsp" }
        var eighths = Int((teaspoons * 8).rounded())
        let quarterCups = eighths / 96
        eighths %= 96
        let tablespoons = eighths / 24
        eighths %= 24
        var parts: [String] = []
        if quarterCups > 0 {
            let cups = fraction(eighths: quarterCups * 2)
            parts.append("\(cups) \(quarterCups <= 4 ? "cup" : "cups")")
        }
        if tablespoons > 0 { parts.append("\(tablespoons) Tbsp") }
        if eighths > 0 { parts.append("\(fraction(eighths: eighths)) tsp") }
        return parts.joined(separator: " + ")
    }

    private static func fraction(eighths: Int) -> String {
        let whole = eighths / 8
        let symbols = ["", "⅛", "¼", "⅜", "½", "⅝", "¾", "⅞"]
        return (whole > 0 ? whole.formatted() : "") + symbols[eighths % 8]
    }
}
