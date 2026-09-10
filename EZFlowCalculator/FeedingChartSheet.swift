import PDFKit
import SwiftUI

struct FeedingChartSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var document = FeedingChart.url.flatMap { PDFDocument(url: $0) }

    var body: some View {
        NavigationStack {
            Group {
                if let document {
                    FeedingChartPDFView(document: document)
                } else {
                    ContentUnavailableView("Chart unavailable", systemImage: "doc.text", description: Text("The feeding chart could not be opened."))
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("2022 Hose Bib Feed Chart by EZ-FLO")
                    Text("Hosted by Drip Depot. Original PDF shown unchanged.")
                        .foregroundStyle(.secondary)
                    if let sourceURL = FeedingChart.sourceURL {
                        Link("Open original PDF on Drip Depot", destination: sourceURL)
                    }
                }
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.bar)
            }
            .navigationTitle("Feeding Chart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
