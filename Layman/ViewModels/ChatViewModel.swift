import Foundation
import SwiftUI
import UIKit

@Observable
final class ChatViewModel {
    var messages: [ChatMessage] = []
    var inputText = ""
    var isLoading = false
    var suggestions: [String] = []
    var showSuggestions = true

    private let articleTitle: String
    private let articleContent: String

    init(articleTitle: String, articleContent: String) {
        self.articleTitle = articleTitle
        self.articleContent = articleContent
        messages.append(ChatMessage(
            content: "Hi, I'm Layman! What can I answer for you?",
            isUser: false
        ))
    }

    func loadSuggestions() async {
        do {
            suggestions = try await GroqService.shared.generateQuestionSuggestions(
                articleTitle: articleTitle,
                articleContent: articleContent
            )
        } catch {
            suggestions = [
                "What does this mean for me?",
                "Why is this important?",
                "What happens next?"
            ]
        }
    }

    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        inputText = ""
        showSuggestions = false

        messages.append(ChatMessage(content: text, isUser: true))
        isLoading = true

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        do {
            let response = try await GroqService.shared.sendMessage(
                userMessage: text,
                articleTitle: articleTitle,
                articleContent: articleContent
            )
            messages.append(ChatMessage(content: response, isUser: false))
        } catch {
            messages.append(ChatMessage(
                content: "Sorry, I couldn't process that. Try asking again!",
                isUser: false
            ))
        }
        isLoading = false
    }

    func selectSuggestion(_ text: String) {
        inputText = text
        Task { await sendMessage() }
    }
}

// UI polish

// UI polish

// Refactoring
