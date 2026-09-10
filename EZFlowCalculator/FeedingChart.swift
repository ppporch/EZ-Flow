import Foundation

enum FeedingChart {
    static let sourceURL = URL(string: "https://www.dripdepot.com/file/parent/1205/1205-2022%20Hose%20Bib%20Feed%20Chart%20Instructions%20v1.pdf")

    static var url: URL? {
        Bundle.main.url(forResource: "1205-2022 Hose Bib Feed Chart Instructions v1", withExtension: "pdf")
    }
}
