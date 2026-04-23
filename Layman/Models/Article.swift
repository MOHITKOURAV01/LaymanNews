import Foundation

struct NewsAPIResponse: Codable, Sendable {
    let status: String?
    let totalResults: Int?
    let results: [Article]?
    let nextPage: String?
}

struct Article: Codable, Identifiable, Sendable, Hashable {
    let articleId: String?
    let title: String?
    let link: String?
    let description: String?
    let content: String?
    let pubDate: String?
    let imageUrl: String?
    let sourceId: String?
    let sourceName: String?
    let sourceUrl: String?
    let category: [String]?
    let country: [String]?
    let language: String?

    enum CodingKeys: String, CodingKey {
        case articleId = "article_id"
        case title, link, description, content
        case pubDate = "pubDate"
        case imageUrl = "image_url"
        case sourceId = "source_id"
        case sourceName = "source_name"
        case sourceUrl = "source_url"
        case category, country, language
    }

    // STABLE id — never random. Falls back to link or title hash.
    var id: String {
        if let aid = articleId, !aid.isEmpty { return aid }
        if let link = link, !link.isEmpty { return link }
        return String((title ?? "unknown").hashValue)
    }

    // Clean, casual headline — max 50 chars, no jargon
    var laymanHeadline: String {
        guard var headline = title, !headline.isEmpty else { return "News Update" }

        // Remove stock tickers like (NYSE:DHR), (NASDAQ:AAPL), (MSTR)
        headline = headline.replacingOccurrences(
            of: #"\s*\([A-Z]+(?::[A-Z]+)?\)\s*"#,
            with: " ",
            options: .regularExpression
        )

        // Remove "- Source Name" suffix
        if let dashRange = headline.range(of: #"\s*[-–—]\s*[A-Z][\w\s]+$"#, options: .regularExpression) {
            headline = String(headline[headline.startIndex..<dashRange.lowerBound])
        }

        // If has colon, take part after colon if it's longer
        if headline.contains(":") {
            let parts = headline.split(separator: ":", maxSplits: 1)
            if parts.count == 2 {
                let afterColon = parts[1].trimmingCharacters(in: .whitespaces)
                if afterColon.count > 15 {
                    headline = afterColon
                }
            }
        }

        // Truncate to ~50 chars at word boundary
        headline = headline.trimmingCharacters(in: .whitespaces)
        if headline.count <= 50 { return headline }

        let words = headline.split(separator: " ")
        var result = ""
        for word in words {
            let candidate = result.isEmpty ? String(word) : result + " " + word
            if candidate.count > 50 { break }
            result = candidate
        }

        return result.isEmpty ? String(headline.prefix(50)) : result
    }

    // Estimated reading time
    var readingTime: String {
        let wordCount = (content ?? description ?? "").split(separator: " ").count
        let minutes = max(1, wordCount / 200)
        return "\(minutes) min read"
    }

    var displayImageUrl: URL? {
        guard let imageUrl = imageUrl, !imageUrl.isEmpty else { return nil }
        return URL(string: imageUrl)
    }

    var sourceURL: URL? {
        guard let link = link, !link.isEmpty else { return nil }
        return URL(string: link)
    }

    // Filter out boring financial articles
    var isInteresting: Bool {
        guard let title = title?.lowercased() else { return true }
        let boringPatterns = [
            "earnings transcript", "price target", "q1 earnings",
            "q2 earnings", "q3 earnings", "q4 earnings",
            "stock price", "shares outstanding", "dividend"
        ]
        return !boringPatterns.contains { title.contains($0) }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.id == rhs.id
    }
}

// UI polish

// UI polish

// Refactoring
