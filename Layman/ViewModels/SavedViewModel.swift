import Foundation
import SwiftUI
import Supabase

@Observable
final class SavedViewModel {
    var savedArticles: [SavedArticle] = []
    var isLoading = false
    var searchText = ""
    var errorMessage: String?
    private var realtimeChannel: RealtimeChannelV2?

    var filteredArticles: [SavedArticle] {
        if searchText.isEmpty { return savedArticles }
        return savedArticles.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    func fetchSavedArticles() async {
        isLoading = true
        errorMessage = nil
        do {
            savedArticles = try await SupabaseService.shared.fetchSavedArticles()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func removeSavedArticle(articleId: String) async {
        do {
            try await SupabaseService.shared.removeSavedArticle(articleId: articleId)
            savedArticles.removeAll { $0.articleId == articleId }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Listen to real-time changes on saved_articles table
    func startRealtimeSync() {
        let channel = SupabaseService.shared.client.realtimeV2.channel("saved_articles_changes")

        let insertions = channel.postgresChange(InsertAction.self, table: "saved_articles")
        let deletions = channel.postgresChange(DeleteAction.self, table: "saved_articles")

        Task {
            await channel.subscribe()

            Task {
                for await insertion in insertions {
                    if let record = try? insertion.decodeRecord(as: SavedArticle.self, decoder: JSONDecoder()) {
                        await MainActor.run {
                            // Avoid duplicates
                            if !savedArticles.contains(where: { $0.articleId == record.articleId }) {
                                savedArticles.insert(record, at: 0)
                            }
                        }
                    }
                }
            }

            Task {
                for await deletion in deletions {
                    if let oldRecord = try? deletion.decodeOldRecord(as: SavedArticle.self, decoder: JSONDecoder()) {
                        await MainActor.run {
                            savedArticles.removeAll { $0.articleId == oldRecord.articleId }
                        }
                    }
                }
            }
        }

        realtimeChannel = channel
    }

    func stopRealtimeSync() {
        Task {
            if let channel = realtimeChannel {
                await SupabaseService.shared.client.realtimeV2.removeChannel(channel)
            }
        }
        realtimeChannel = nil
    }
}
