import Foundation

// For reading from Supabase
struct SavedArticle: Codable, Identifiable, Sendable {
    let id: UUID?
    let userId: UUID?
    let articleId: String
    let title: String
    let description: String?
    let imageUrl: String?
    let sourceUrl: String?
    let sourceName: String?
    let publishedAt: String?
    let content: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case articleId = "article_id"
        case title, description
        case imageUrl = "image_url"
        case sourceUrl = "source_url"
        case sourceName = "source_name"
        case publishedAt = "published_at"
        case content
        case createdAt = "created_at"
    }

    func toArticle() -> Article {
        Article(
            articleId: articleId,
            title: title,
            link: sourceUrl,
            description: description,
            content: content,
            pubDate: publishedAt,
            imageUrl: imageUrl,
            sourceId: nil,
            sourceName: sourceName,
            sourceUrl: sourceUrl,
            category: nil,
            country: nil,
            language: nil
        )
    }
}

// For inserting to Supabase — only user-controlled fields, no id/created_at
struct SavedArticleInsert: Codable, Sendable {
    let userId: UUID
    let articleId: String
    let title: String
    let description: String?
    let imageUrl: String?
    let sourceUrl: String?
    let sourceName: String?
    let publishedAt: String?
    let content: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case articleId = "article_id"
        case title, description
        case imageUrl = "image_url"
        case sourceUrl = "source_url"
        case sourceName = "source_name"
        case publishedAt = "published_at"
        case content
    }
}
