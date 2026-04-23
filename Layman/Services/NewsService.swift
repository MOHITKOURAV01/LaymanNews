import Foundation

enum NewsServiceError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case noResults

    nonisolated var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL"
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        case .decodingError(let error): return "Data error: \(error.localizedDescription)"
        case .noResults: return "No articles found"
        }
    }
}

struct NewsPage: Sendable {
    let articles: [Article]
    let nextPage: String?
}

nonisolated final class NewsService: Sendable {
    static let shared = NewsService()
    private let baseURL = "https://newsdata.io/api/1/latest"

    private init() {}

    func fetchArticles(category: String = "business,technology", language: String = "en", page: String? = nil) async throws -> NewsPage {
        let apiKey = AppConfig.newsAPIKey
        guard var components = URLComponents(string: baseURL) else {
            throw NewsServiceError.invalidURL
        }

        var queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "category", value: category),
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "country", value: "us,gb,in"),
            URLQueryItem(name: "image", value: "1"),
            URLQueryItem(name: "removeduplicate", value: "1"),
            URLQueryItem(name: "size", value: "10")
        ]

        if let page = page {
            queryItems.append(URLQueryItem(name: "page", value: page))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw NewsServiceError.invalidURL
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw NewsServiceError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NewsServiceError.noResults
        }

        let apiResponse: NewsAPIResponse
        do {
            apiResponse = try JSONDecoder().decode(NewsAPIResponse.self, from: data)
        } catch {
            throw NewsServiceError.decodingError(error)
        }

        guard let articles = apiResponse.results, !articles.isEmpty else {
            throw NewsServiceError.noResults
        }

        // Filter: must have title, English content, not boring financial news
        let filtered = articles.filter { article in
            guard let title = article.title, !title.isEmpty else { return false }
            let latinCount = title.unicodeScalars.filter { $0.isASCII }.count
            return Double(latinCount) / Double(title.count) > 0.7 && article.isInteresting
        }

        return NewsPage(
            articles: filtered.isEmpty ? articles : filtered,
            nextPage: apiResponse.nextPage
        )
    }
}
