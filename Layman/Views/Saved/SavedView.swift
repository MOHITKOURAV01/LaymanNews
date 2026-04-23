import SwiftUI

struct SavedView: View {
    @State private var viewModel = SavedViewModel()
    @State private var showSearch = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack {
                        Text("Saved")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.textPrimary)

                        Spacer()

                        if !viewModel.savedArticles.isEmpty {
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
                    }
                    .padding(.horizontal, AppConstants.standardPadding)
                    .padding(.top, 8)

                    // Search bar
                    if showSearch {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.textSecondary)
                                .font(.system(size: 15))
                            TextField("Search saved...", text: $viewModel.searchText)
                                .font(.system(size: 15))
                                .autocapitalization(.none)
                        }
                        .padding(12)
                        .background(Color.searchBarBg)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, AppConstants.standardPadding)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    if viewModel.isLoading && viewModel.savedArticles.isEmpty {
                        Spacer()
                        ProgressView()
                            .tint(.primaryOrange)
                            .frame(maxWidth: .infinity)
                        Spacer()
                    } else if viewModel.filteredArticles.isEmpty && viewModel.searchText.isEmpty {
                        // Empty state
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "bookmark")
                                .font(.system(size: 50))
                                .foregroundColor(.tabInactive)
                            Text("No saved articles yet")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.textPrimary)
                            Text("Tap the bookmark icon on any article\nto save it here.")
                                .font(.system(size: 14))
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        Spacer()
                    } else if viewModel.filteredArticles.isEmpty && !viewModel.searchText.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 36))
                                .foregroundColor(.tabInactive)
                            Text("No results for \"\(viewModel.searchText)\"")
                                .font(.system(size: 15))
                                .foregroundColor(.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        Spacer()
                    } else {
                        List {
                            ForEach(viewModel.filteredArticles) { saved in
                                NavigationLink(value: saved.toArticle()) {
                                    ArticleRow(article: saved.toArticle())
                                }
                                .buttonStyle(.plain)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    let article = viewModel.filteredArticles[index]
                                    Task {
                                        await viewModel.removeSavedArticle(articleId: article.articleId)
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationDestination(for: Article.self) { article in
                ArticleDetailView(article: article)
            }
        }
        .task {
            await viewModel.fetchSavedArticles()
            viewModel.startRealtimeSync()
        }
        .refreshable {
            await viewModel.fetchSavedArticles()
        }
        .onDisappear {
            viewModel.stopRealtimeSync()
        }
    }
}

// UI polish

// UI polish

// UI polish

// UI polish

// Refactoring

// Refactoring
