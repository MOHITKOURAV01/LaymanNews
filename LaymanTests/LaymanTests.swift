import XCTest
@testable import Layman

@MainActor
final class LaymanTests: XCTestCase {

    func testArticleModelDecoding() throws {
        // Given
        let json = """
        {
            "article_id": "123",
            "title": "Apple announces new AI features",
            "link": "https://apple.com",
            "source_id": "apple_news",
            "source_name": "Apple News",
            "pubDate": "2026-04-24",
            "description": "Apple has announced a new suite of AI tools.",
            "content": "Full content goes here."
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let article = try decoder.decode(Article.self, from: json)
        
        // Then
        XCTAssertEqual(article.id, "123")
        XCTAssertEqual(article.title, "Apple announces new AI features")
        XCTAssertEqual(article.sourceName, "Apple News")
        XCTAssertEqual(article.description, "Apple has announced a new suite of AI tools.")
    }

    func testSavedArticleInitialization() {
        // Given
        let article = Article(
            articleId: "abc",
            title: "Test Title",
            link: "https://test.com",
            description: "Test Desc",
            content: "Test Content",
            pubDate: "2026",
            imageUrl: "https://img.com",
            sourceId: "src",
            sourceName: "Source Name",
            sourceUrl: "https://src.com",
            category: ["tech"],
            country: ["us"],
            language: "en"
        )
        
        let userId = UUID()
        
        // When
        let saved = SavedArticle(
            id: UUID(),
            userId: userId,
            articleId: article.id,
            title: article.title ?? "Untitled",
            description: article.description,
            imageUrl: article.imageUrl,
            sourceUrl: article.link,
            sourceName: article.sourceName,
            publishedAt: article.pubDate,
            content: article.content,
            createdAt: "2026-04-24"
        )
        
        // Then
        XCTAssertEqual(saved.articleId, "abc")
        XCTAssertEqual(saved.title, "Test Title")
        XCTAssertEqual(saved.userId, userId)
    }
}
