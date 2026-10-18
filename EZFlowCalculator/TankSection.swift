import SwiftUI

struct TankSection: View {
    @Binding var tankSize: TankSize
    @State private var showingFeedingChart = false

    var body: some View {
        Section("Tank") {
            Picker("Fertigator size", selection: $tankSize) {
                ForEach(TankSize.allCases) { size in
                    Text(size.displayName).tag(size)
                }
            }
            LabeledContent("Model", value: tankSize.model)
            Button("View feeding chart", systemImage: "doc.text") {
                showingFeedingChart = true
            }
            // Attach to the row, not the Section: Form applies Section modifiers to every row.
            .sheet(isPresented: $showingFeedingChart) {
                FeedingChartSheet()
            }
        }
    }
}
