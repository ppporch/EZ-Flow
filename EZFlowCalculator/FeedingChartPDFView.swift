import PDFKit
import SwiftUI

struct FeedingChartPDFView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.document = document
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        return view
    }

    func updateUIView(_ view: PDFView, context: Context) {
        if view.document !== document {
            view.document = document
        }
    }
}
