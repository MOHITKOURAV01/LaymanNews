import Foundation
import SwiftUI

@Observable
final class ArticlesViewModel {
    var articles: [Article] = []
    var isLoading = false
    var isLoadingMore = false
    var searchText = ""
    var errorMessage: String?
    private var nextPage: String?
    private var hasMorePages = true

    var featuredArticles: [Article] {
        Array(articles.prefix(5))
    }

    var todaysPicks: [Article] {
        Array(articles.dropFirst(5))
    }

    var filteredArticles: [Article] {
        if searchText.isEmpty { return todaysPicks }
        return todaysPicks.filter {
            ($0.title ?? "").localizedCaseInsensitiveContains(searchText) ||
            ($0.description ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    func fetchArticles() async {
        isLoading = true
        errorMessage = nil

        do {
            let page = try await NewsService.shared.fetchArticles()
            articles = page.articles
            nextPage = page.nextPage
            hasMorePages = page.nextPage != nil
            cacheArticles()
        } catch {
            errorMessage = error.localizedDescription
            loadCachedArticles()
        }
        isLoading = false
    }

    func loadMoreIfNeeded(currentArticle: Article) async {
        // Trigger when near end of list
        guard let index = todaysPicks.firstIndex(where: { $0.id == currentArticle.id }) else { return }
        guard index >= todaysPicks.count - 3 else { return }
        await loadNextPage()
    }

    func loadNextPage() async {
        guard !isLoadingMore, hasMorePages, let page = nextPage else { return }
        isLoadingMore = true

        do {
            let result = try await NewsService.shared.fetchArticles(page: page)
            // Avoid duplicates
            let existingIds = Set(articles.map(\.id))
            let newArticles = result.articles.filter { !existingIds.contains($0.id) }
            articles.append(contentsOf: newArticles)
            nextPage = result.nextPage
            hasMorePages = result.nextPage != nil
            cacheArticles()
        } catch {
            // Silent fail for pagination
        }
        isLoadingMore = false
    }

    private func cacheArticles() {
        if let data = try? JSONEncoder().encode(articles) {
            UserDefaults.standard.set(data, forKey: "cachedArticles")
        }
    }

    private func loadCachedArticles() {
        if let data = UserDefaults.standard.data(forKey: "cachedArticles"),
           let cached = try? JSONDecoder().decode([Article].self, from: data) {
            articles = cached
            errorMessage = nil
        }
    }
}
