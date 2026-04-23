import SwiftUI
import UIKit

struct ArticleDetailView: View {
    let article: Article

    @Environment(\.dismiss) private var dismiss
    @State private var isSaved = false
    @State private var bookmarkScale: CGFloat = 1.0
    @State private var showWebView = false
    @State private var showChat = false
    @State private var contentCards: [String] = []
    @State private var isLoadingCards = true
    @State private var currentCardIndex = 0
    @State private var showSaveToast = false
    @State private var toastMessage = ""
    @AppStorage("articlesReadCount") private var articlesReadCount = 0
    @AppStorage("readingStreak") private var readingStreak = 0
    @AppStorage("lastReadDate") private var lastReadDate: Double = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Custom nav bar
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.textPrimary)
                                .frame(width: 36, height: 36)
                                .background(Color.cardWhite.opacity(0.9))
                                .clipShape(Circle())
                        }

                        Spacer()

                        HStack(spacing: 12) {
                            Button { showWebView = true } label: {
                                Image(systemName: "link")
                                    .font(.system(size: 16))
                                    .foregroundColor(.textPrimary)
                                    .frame(width: 36, height: 36)
                                    .background(Color.cardWhite.opacity(0.9))
                                    .clipShape(Circle())
                            }

                            Button { toggleBookmark() } label: {
                                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: 16))
                                    .foregroundColor(isSaved ? .primaryOrange : .textPrimary)
                                    .frame(width: 36, height: 36)
                                    .background(Color.cardWhite.opacity(0.9))
                                    .clipShape(Circle())
                                    .scaleEffect(bookmarkScale)
                            }

                            if let url = article.sourceURL {
                                ShareLink(item: url) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 16))
                                        .foregroundColor(.textPrimary)
                                        .frame(width: 36, height: 36)
                                        .background(Color.cardWhite.opacity(0.9))
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppConstants.standardPadding)

                    // Headline
                    Text(article.title ?? "")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, AppConstants.standardPadding)

                    // Source
                    if let source = article.sourceName {
                        Text(source)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.textSecondary)
                            .padding(.horizontal, AppConstants.standardPadding)
                    }

                    // Image
                    AsyncImage(url: article.displayImageUrl) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            LinearGradient(
                                colors: [.gradientStart, .gradientEnd],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .overlay(
                                Image(systemName: "newspaper.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.5))
                            )
                        }
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadiusCard))
                    .padding(.horizontal, AppConstants.standardPadding)

                    // Content Cards
                    VStack(spacing: 10) {
                        if isLoadingCards {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .tint(.primaryOrange)
                                    .scaleEffect(1.2)
                                Text("Simplifying for you...")
                                    .font(.system(size: 14))
                                    .foregroundColor(.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .background(Color.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadiusCard))
                            .padding(.horizontal, AppConstants.standardPadding)
                        } else if !contentCards.isEmpty {
                            TabView(selection: $currentCardIndex) {
                                ForEach(Array(contentCards.enumerated()), id: \.offset) { index, card in
                                    ContentCard(text: card)
                                        .padding(.horizontal, AppConstants.standardPadding)
                                        .rotation3DEffect(
                                            .degrees(currentCardIndex == index ? 0 : (currentCardIndex > index ? -5 : 5)),
                                            axis: (x: 0, y: 1, z: 0)
                                        )
                                        .scaleEffect(currentCardIndex == index ? 1.0 : 0.93)
                                        .opacity(currentCardIndex == index ? 1.0 : 0.6)
                                        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: currentCardIndex)
                                        .tag(index)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .frame(height: 210)

                            // Page indicator dots
                            HStack(spacing: 8) {
                                ForEach(0..<contentCards.count, id: \.self) { index in
                                    Capsule()
                                        .fill(index == currentCardIndex ? Color.primaryOrange : Color.tabInactive.opacity(0.35))
                                        .frame(
                                            width: index == currentCardIndex ? 24 : 8,
                                            height: 8
                                        )
                                        .scaleEffect(index == currentCardIndex ? 1.0 : 0.85)
                                        .animation(.spring(response: 0.35, dampingFraction: 0.6, blendDuration: 0.1), value: currentCardIndex)
                                }
                            }
                        }
                    }

                    Spacer().frame(height: 80)
                }
            }

            // Ask Layman Button
            VStack(spacing: 0) {
                Button { showChat = true } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bubble.left.and.text.bubble.right.fill")
                            .font(.system(size: 15))
                        Text("Ask Layman")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.primaryOrange)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadiusButton))
                    .shadow(color: Color.primaryOrange.opacity(0.3), radius: 8, y: 4)
                }
                .padding(.horizontal, AppConstants.standardPadding)
                .padding(.bottom, 12)
                .background(
                    Color.appBackground
                        .shadow(color: .black.opacity(0.05), radius: 8, y: -4)
                )
            }

            // Toast
            if showSaveToast {
                VStack {
                    Spacer()
                    Text(toastMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.textPrimary.opacity(0.9))
                        .clipShape(Capsule())
                        .padding(.bottom, 90)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(response: 0.4), value: showSaveToast)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showWebView) {
            if let url = article.sourceURL {
                WebViewSheet(url: url)
            }
        }
        .sheet(isPresented: $showChat) {
            NavigationStack {
                ChatView(articleTitle: article.title ?? "", articleContent: article.content ?? article.description ?? "")
            }
        }
        .task {
            trackArticleRead()
            await checkIfSaved()
            await loadContentCards()
        }
    }

    private func toggleBookmark() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            bookmarkScale = 1.35
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                bookmarkScale = 1.0
            }
        }

        Task {
            do {
                if isSaved {
                    try await SupabaseService.shared.removeSavedArticle(articleId: article.id)
                    isSaved = false
                    showToast("Removed from saved")
                } else {
                    try await SupabaseService.shared.saveArticle(from: article)
                    isSaved = true
                    showToast("Article saved!")
                }
            } catch SupabaseError.notAuthenticated {
                showToast("Please sign in to save articles")
            } catch {
                // Retry once after refreshing session
                do {
                    _ = try await SupabaseService.shared.getSession()
                    if isSaved {
                        try await SupabaseService.shared.removeSavedArticle(articleId: article.id)
                        isSaved = false
                        showToast("Removed from saved")
                    } else {
                        try await SupabaseService.shared.saveArticle(from: article)
                        isSaved = true
                        showToast("Article saved!")
                    }
                } catch {
                    showToast("Failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showToast(_ message: String) {
        toastMessage = message
        withAnimation { showSaveToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showSaveToast = false }
        }
    }

    private func checkIfSaved() async {
        isSaved = await SupabaseService.shared.isArticleSaved(articleId: article.id)
    }

    private func loadContentCards() async {
        let title = article.title ?? ""
        let content = article.content ?? article.description ?? ""

        if content.count > 30 {
            do {
                contentCards = try await GroqService.shared.generateContentCards(
                    articleTitle: title,
                    articleContent: content
                )
            } catch {
                contentCards = generateFallbackCards(content: content)
            }
        } else {
            contentCards = generateFallbackCards(content: content)
        }
        isLoadingCards = false
    }

    // MARK: - Reading Stats

    private func trackArticleRead() {
        let articleId = article.id

        // Load read IDs set
        var readIds: Set<String> = []
        if let data = UserDefaults.standard.data(forKey: "readArticleIds"),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            readIds = decoded
        }

        // Only count if not already read
        guard !readIds.contains(articleId) else { return }

        // Mark as read
        readIds.insert(articleId)
        if let encoded = try? JSONEncoder().encode(readIds) {
            UserDefaults.standard.set(encoded, forKey: "readArticleIds")
        }
        articlesReadCount += 1

        // Update streak
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())

        if lastReadDate == 0 {
            // First time ever
            readingStreak = 1
            lastReadDate = todayStart.timeIntervalSince1970
        } else {
            let lastDate = calendar.startOfDay(for: Date(timeIntervalSince1970: lastReadDate))
            if lastDate == todayStart {
                // Already read today — streak stays same
            } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: todayStart),
                      lastDate == calendar.startOfDay(for: yesterday) {
                // Read yesterday — increment streak
                readingStreak += 1
                lastReadDate = todayStart.timeIntervalSince1970
            } else {
                // Missed a day — reset streak
                readingStreak = 1
                lastReadDate = todayStart.timeIntervalSince1970
            }
        }
    }

    private func generateFallbackCards(content: String) -> [String] {
        let desc = article.description ?? article.title ?? "This article covers recent news."
        return [
            String(desc.prefix(120)) + (desc.count > 120 ? "..." : ""),
            "This could impact how businesses and regular people interact with technology going forward. Experts are watching closely for further developments.",
            "Stay tuned as this story continues to unfold. More updates are expected in the coming days and weeks."
        ]
    }
}

// UI polish

// UI polish
