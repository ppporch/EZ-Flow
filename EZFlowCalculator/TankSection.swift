import SwiftUI

struct TankSection: View {
    @Binding var tankSize: TankSize
    @State private var showingFeedingChart = false

    var body: some View {
        Section("Tank") {
            Picker("Fertigator size", selection: $tankSize) {
                ForEach(TankSize.allCases) { size in
                    Text(size.rawValue).tag(size)
                }
            }
            LabeledContent("Model", value: tankSize.model)
            Button("View feeding chart", systemImage: "doc.text") {
                showingFeedingChart = true
            }
        }
        .sheet(isPresented: $showingFeedingChart) {
            FeedingChartSheet()
        }
    }
}
