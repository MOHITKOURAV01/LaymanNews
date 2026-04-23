import Foundation
import Supabase
import Auth

/// Singleton service for all Supabase auth and database operations.
nonisolated final class SupabaseService: Sendable {
    static let shared = SupabaseService()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: AppConfig.supabaseURL)!,
            supabaseKey: AppConfig.supabaseAnonKey
        )
    }

    // MARK: - Auth

    func signUp(email: String, password: String) async throws {
        try await client.auth.signUp(email: email, password: password)
    }

    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    func getSession() async throws -> Session {
        try await client.auth.session
    }

    func getCurrentUserId() -> UUID? {
        client.auth.currentUser?.id
    }

    func getCurrentUserEmail() -> String? {
        client.auth.currentUser?.email
    }

    // MARK: - Save Article

    func saveArticle(from article: Article) async throws {
        guard let userId = getCurrentUserId() else {
            throw SupabaseError.notAuthenticated
        }

        let insertData = SavedArticleInsert(
            userId: userId,
            articleId: article.id,
            title: article.title ?? "Untitled",
            description: article.description,
            imageUrl: article.imageUrl,
            sourceUrl: article.link,
            sourceName: article.sourceName,
            publishedAt: article.pubDate,
            content: article.content
        )

        do {
            try await client.from("saved_articles")
                .insert(insertData)
                .execute()
        } catch {
            let errorStr = "\(error)"
            // Duplicate is OK — article already saved
            if errorStr.contains("duplicate") || errorStr.contains("23505") {
                return
            }
            throw SupabaseError.saveFailed(errorStr)
        }
    }

    // MARK: - Remove Saved Article

    func removeSavedArticle(articleId: String) async throws {
        guard let userId = getCurrentUserId() else { return }
        try await client.from("saved_articles")
            .delete()
            .eq("article_id", value: articleId)
            .eq("user_id", value: userId.uuidString)
            .execute()
    }

    // MARK: - Fetch Saved Articles

    func fetchSavedArticles() async throws -> [SavedArticle] {
        guard let userId = getCurrentUserId() else {
            throw SupabaseError.notAuthenticated
        }
        return try await client.from("saved_articles")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    // MARK: - Check if Saved

    func fetchSavedArticleIds() async -> Set<String> {
        guard let userId = getCurrentUserId() else { return [] }
        struct IdOnly: Decodable, Sendable {
            let articleId: String
            enum CodingKeys: String, CodingKey { case articleId = "article_id" }
        }
        let result: [IdOnly]? = try? await client.from("saved_articles")
            .select("article_id")
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value
        return Set(result?.map(\.articleId) ?? [])
    }

    func isArticleSaved(articleId: String) async -> Bool {
        let ids = await fetchSavedArticleIds()
        return ids.contains(articleId)
    }
}

// MARK: - Errors

enum SupabaseError: LocalizedError, Sendable {
    case notAuthenticated
    case saveFailed(String)

    nonisolated var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "Please sign in to save articles"
        case .saveFailed(let msg): return "Save failed: \(msg)"
        }
    }
}

// UI polish

// UI polish
