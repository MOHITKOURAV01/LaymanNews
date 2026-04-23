import SwiftUI
import UIKit

struct HomeView: View {
    @State private var viewModel = ArticlesViewModel()
    @State private var showSearch = false
    @AppStorage("readingStreak") private var readingStreak = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if viewModel.isLoading && viewModel.articles.isEmpty {
                    SkeletonLoadingView()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Header
                            HStack(alignment: .center, spacing: 8) {
                                Text("Layman")
                                    .font(.system(size: 28, weight: .bold, design: .serif))
                                    .foregroundColor(.textPrimary)

                                if readingStreak > 0 {
                                    HStack(spacing: 2) {
                                        Image(systemName: "flame.fill")
                                            .font(.system(size: 12))
                                        Text("\(readingStreak)")
                                            .font(.system(size: 12, weight: .bold))
                                    }
                                    .foregroundColor(.primaryOrange)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.cardBackground)
                                    .clipShape(Capsule())
                                }

                                Spacer()

                                Button {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        showSearch.toggle()
                                        if !showSearch { viewModel.searchText = "" }
                                    }
                                } label: {
                                    Image(systemName: showSearch ? "xmark.circle.fill" : "magnifyingglass")
                                        .font(.system(size: 20))
                                        .foregroundColor(.textPrimary)
                                }
                            }
                            .padding(.horizontal, AppConstants.standardPadding)
                            .padding(.top, 8)

                            // Search bar
                            if showSearch {
                                HStack(spacing: 8) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.textSecondary)
                                        .font(.system(size: 15))
                                    TextField("Search articles...", text: $viewModel.searchText)
                                        .font(.system(size: 15))
                                        .autocapitalization(.none)
                                        .submitLabel(.search)
                                }
                                .padding(12)
                                .background(Color.searchBarBg)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal, AppConstants.standardPadding)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            // Featured Carousel
                            if !viewModel.featuredArticles.isEmpty && viewModel.searchText.isEmpty {
                                FeaturedCarousel(articles: viewModel.featuredArticles)
                            }

                            // Today's Picks
                            if !viewModel.filteredArticles.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text(viewModel.searchText.isEmpty ? "Today's Picks" : "Results")
                                            .font(.sectionHeader)
                                            .foregroundColor(.textPrimary)
                                        Spacer()
                                        if viewModel.searchText.isEmpty {
                                            NavigationLink {
                                                AllArticlesView(articles: viewModel.articles)
                                            } label: {
                                                Text("View All")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.primaryOrange)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal, AppConstants.standardPadding)

                                    LazyVStack(spacing: 10) {
                                        ForEach(Array(viewModel.filteredArticles.enumerated()), id: \.element.id) { index, article in
                                            NavigationLink(value: article) {
                                                ArticleRow(article: article)
                                            }
                                            .buttonStyle(.plain)
                                            .onAppear {
                                                Task { await viewModel.loadMoreIfNeeded(currentArticle: article) }
                                            }
                                        }

                                        // Loading more indicator
                                        if viewModel.isLoadingMore {
                                            HStack {
                                                Spacer()
                                                ProgressView()
                                                    .tint(.primaryOrange)
                                                Text("Loading more...")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.textSecondary)
                                                Spacer()
                                            }
                                            .padding(.vertical, 12)
                                        }
                                    }
                                    .padding(.horizontal, AppConstants.standardPadding)
                                }
                            }

                            // Empty search
                            if !viewModel.searchText.isEmpty && viewModel.filteredArticles.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 36))
                                        .foregroundColor(.tabInactive)
                                    Text("No articles match \"\(viewModel.searchText)\"")
                                        .font(.system(size: 15))
                                        .foregroundColor(.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                            }

                            // Error
                            if let error = viewModel.errorMessage, viewModel.articles.isEmpty {
                                VStack(spacing: 14) {
                                    Image(systemName: "wifi.slash")
                                        .font(.system(size: 40))
                                        .foregroundColor(.tabInactive)
                                    Text("Couldn't load articles")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.textPrimary)
                                    Text(error)
                                        .font(.system(size: 14))
                                        .foregroundColor(.textSecondary)
                                        .multilineTextAlignment(.center)
                                    Button("Try Again") {
                                        Task { await viewModel.fetchArticles() }
                                    }
                                    .primaryButtonStyle()
                                    .frame(width: 140)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 60)
                            }

                            // Bottom padding so last row isn't hidden behind tab bar
                            Spacer().frame(height: 40)
                        }
                    }
                    .refreshable {
                        await viewModel.fetchArticles()
                    }
                }
            }
            .navigationDestination(for: Article.self) { article in
                ArticleDetailView(article: article)
            }
        }
        .task {
            await viewModel.fetchArticles()
        }
        .onTapGesture { hideKeyboard() }
    }
}

// MARK: - All Articles

struct AllArticlesView: View {
    let articles: [Article]
    @State private var searchText = ""
    @State private var selectedArticle: Article?

    var filtered: [Article] {
        if searchText.isEmpty { return articles }
        return articles.filter { ($0.title ?? "").localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(filtered) { article in
                        Button {
                            selectedArticle = article
                        } label: {
                            ArticleRow(article: article)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppConstants.standardPadding)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("All Articles")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search articles...")
        .fullScreenCover(item: $selectedArticle) { article in
            NavigationStack {
                ArticleDetailView(article: article)
            }
        }
    }
}

// MARK: - Skeleton

struct SkeletonLoadingView: View {
    @State private var shimmer = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                RoundedRectangle(cornerRadius: 8).fill(Color.cardBackground).frame(width: 120, height: 30)
                Spacer()
                Circle().fill(Color.cardBackground).frame(width: 30, height: 30)
            }
            .padding(.horizontal, 16)

            RoundedRectangle(cornerRadius: 16).fill(Color.cardBackground).frame(height: 220).padding(.horizontal, 16)

            ForEach(0..<5, id: \.self) { _ in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 12).fill(Color.cardBackground).frame(width: 60, height: 60)
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4).fill(Color.cardBackground).frame(height: 14)
                        RoundedRectangle(cornerRadius: 4).fill(Color.cardBackground).frame(width: 100, height: 12)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            Spacer()
        }
        .opacity(shimmer ? 0.4 : 0.8)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: shimmer)
        .onAppear { shimmer = true }
    }
}

// UI polish

// UI polish

// UI polish

// UI polish

// Refactoring

// Refactoring

// Refactoring
