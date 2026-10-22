import Foundation
import Testing
@testable import EZFlowCalculator

struct NumericEntryTests {
    @Test(arguments: ["", "1/2", "2 tsp", "½", "1.2.3", "nan", "inf", "1e999"])
    func invalidPastedRateCannotBecomeANumericPrefix(text: String) {
        #expect(NumericEntry.decimal(text, locale: Locale(identifier: "en_US")) == nil)
    }

    @Test func acceptsDecimalRatesAndLocalizedSeparators() {
        #expect(NumericEntry.decimal("0.5", locale: Locale(identifier: "en_US")) == 0.5)
        #expect(NumericEntry.decimal("0,5", locale: Locale(identifier: "de_DE")) == 0.5)
        #expect(NumericEntry.decimal("1,200.5", locale: Locale(identifier: "en_US")) == 1200.5)
        #expect(NumericEntry.decimal("0.0000001", locale: Locale(identifier: "en_US")) == 0.0000001)
    }

    @Test(arguments: ["", "1.5", "1/2", "2 drippers", "9999999999999999999999999999"])
    func dripperCountsRequireAWholeNumber(text: String) {
        #expect(NumericEntry.integer(text, locale: Locale(identifier: "en_US")) == nil)
    }
}
