import Testing
@testable import EZFlowCalculator

struct KitchenMeasurementTests {
    @Test(arguments: [
        (0.0, "0 tsp"), (0.01, "Less than ⅛ tsp"), (0.0625, "⅛ tsp"),
        (0.125, "⅛ tsp"), (0.25, "¼ tsp"), (0.5, "½ tsp"), (0.75, "¾ tsp"),
        (1.125, "1⅛ tsp"), (2.5, "2½ tsp"), (3, "1 Tbsp"),
        (4.5, "1 Tbsp + 1½ tsp"), (11.99, "¼ cup"), (12, "¼ cup"),
        (18.75, "¼ cup + 2 Tbsp + ¾ tsp"), (48, "1 cup"),
        (62.5, "1¼ cups + 2½ tsp"), (96, "2 cups"),
        (375, "7¾ cups + 1 Tbsp")
    ])
    func familiarMeasurements(teaspoons: Double, expected: String) {
        #expect(KitchenMeasurement.summary(teaspoons: teaspoons) == expected)
    }

    @Test(arguments: [Double.nan, Double.infinity, -1, Double.greatestFiniteMagnitude])
    func invalidMeasurementsDoNotOverflow(value: Double) {
        #expect(KitchenMeasurement.summary(teaspoons: value) == "Check amount")
    }
}
