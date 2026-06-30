enum FeedSetting: String, CaseIterable, Identifiable {
    case slow = "Slow"
    case one = "1"
    case two = "2"
    case fast = "Fast"

    var id: String { rawValue }

    func ratio(using flowDisc: FlowDisc) -> Double {
        switch (flowDisc.hasDisc, self) {
        case (false, .slow):
            1000
        case (false, .one):
            500
        case (false, .two):
            250
        case (false, .fast):
            100
        case (true, .slow):
            250
        case (true, .one):
            125
        case (true, .two):
            62.5
        case (true, .fast):
            25
        }
    }
}
