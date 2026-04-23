import Foundation

nonisolated final class GroqService: Sendable {
    static let shared = GroqService()

    private let baseURL = "https://api.groq.com/openai/v1/chat/completions"
    private let model = "llama-3.1-8b-instant"

    private init() {}

    func sendMessage(userMessage: String, articleTitle: String, articleContent: String) async throws -> String {
        let systemPrompt = """
        You are Layman, a friendly assistant that explains news simply.
        Article: \(articleTitle)
        Context: \(articleContent.prefix(500))
        Rules:
        - Answer in exactly 1-2 short sentences
        - Use simple everyday language a teenager would understand
        - Never use jargon or technical terms
        - Stay relevant to the article
        - If asked something unrelated, gently redirect
        """

        return try await makeRequest(
            systemPrompt: systemPrompt,
            userMessage: userMessage,
            maxTokens: 120,
            temperature: 0.7
        )
    }

    func generateQuestionSuggestions(articleTitle: String, articleContent: String) async throws -> [String] {
        let systemPrompt = "Generate exactly 3 short curious questions about a news article. Each question: 5-10 words, simple, conversational. Return ONLY 3 questions, one per line. No numbering, no quotes, no dashes."

        let userMessage = "Article: \(articleTitle)\nContent: \(String(articleContent.prefix(300)))"

        let response = try await makeRequest(
            systemPrompt: systemPrompt,
            userMessage: userMessage,
            maxTokens: 80,
            temperature: 0.8
        )

        let questions = response.components(separatedBy: "\n")
            .map { line in
                var cleaned = line.trimmingCharacters(in: .whitespacesAndNewlines)
                // Strip numbering like "1." "1)" "- " "* "
                if let range = cleaned.range(of: #"^[\d\-\*\•]+[\.\)\:\s]*\s*"#, options: .regularExpression) {
                    cleaned.removeSubrange(range)
                }
                // Strip quotes
                cleaned = cleaned.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                return cleaned
            }
            .filter { !$0.isEmpty && $0.count > 5 }
            .prefix(3)

        guard questions.count >= 2 else {
            return [
                "What does this mean for me?",
                "Why is this important?",
                "What happens next?"
            ]
        }

        return Array(questions)
    }

    func generateContentCards(articleTitle: String, articleContent: String) async throws -> [String] {
        let systemPrompt = """
        Summarize this article in 3 parts. Rules:
        - Each part: exactly 2 simple sentences, 28-35 words total
        - Write like explaining to a friend who knows nothing about business
        - Use everyday words, no jargon
        - Separate each part with ---
        - No numbering, no labels, no headers
        - Card 1: What happened
        - Card 2: Why it matters to regular people
        - Card 3: What might happen next
        """

        let userMessage = "Title: \(articleTitle)\nContent: \(String(articleContent.prefix(600)))"

        let response = try await makeRequest(
            systemPrompt: systemPrompt,
            userMessage: userMessage,
            maxTokens: 250,
            temperature: 0.6
        )

        let cards = response.components(separatedBy: "---")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count > 20 }

        if cards.count >= 3 {
            return Array(cards.prefix(3))
        }

        // Fallback: split by double newline
        let byNewline = response.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count > 20 }

        if byNewline.count >= 3 {
            return Array(byNewline.prefix(3))
        }

        // Final fallback
        let desc = articleContent.isEmpty ? articleTitle : String(articleContent.prefix(200))
        return [
            "Here's what happened: \(String(desc.prefix(80))). This is a developing story worth keeping an eye on.",
            "This matters because it could change how regular people deal with these things. It's part of a bigger trend that's been building up.",
            "Experts think we'll see more developments soon. Stay tuned — this story is likely to keep evolving over the coming weeks."
        ]
    }

    // MARK: - Private

    private func makeRequest(systemPrompt: String, userMessage: String, maxTokens: Int, temperature: Double) async throws -> String {
        let apiKey = AppConfig.groqAPIKey
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15

        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userMessage]
            ],
            "max_tokens": maxTokens,
            "temperature": temperature
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let first = choices.first,
              let message = first["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw URLError(.cannotParseResponse)
        }

        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
