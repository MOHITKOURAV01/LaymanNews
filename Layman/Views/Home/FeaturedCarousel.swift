import SwiftUI
import Combine

struct FeaturedCarousel: View {
    let articles: [Article]
    @State private var currentIndex = 0

    var body: some View {
        VStack(spacing: 10) {
            TabView(selection: $currentIndex) {
                ForEach(Array(articles.enumerated()), id: \.element.id) { index, article in
                    NavigationLink(value: article) {
                        carouselCard(article: article, index: index)
                    }
                    .buttonStyle(.plain)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: AppConstants.carouselHeight)
            .onReceive(
                Foundation.Timer.publish(every: 4, on: .main, in: .common).autoconnect()
            ) { _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentIndex = (currentIndex + 1) % max(articles.count, 1)
                }
            }

            // Custom page dots
            HStack(spacing: 6) {
                ForEach(0..<articles.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? Color.primaryOrange : Color.tabInactive.opacity(0.5))
                        .frame(width: index == currentIndex ? 8 : 6, height: index == currentIndex ? 8 : 6)
                        .animation(.easeInOut(duration: 0.2), value: currentIndex)
                }
            }
        }
    }

    @ViewBuilder
    private func carouselCard(article: Article, index: Int) -> some View {
        ZStack(alignment: .bottomLeading) {
            // Image
            AsyncImage(url: article.displayImageUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    LinearGradient(
                        colors: [Color.gradientStart, Color.gradientEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .overlay(
                        Image(systemName: "newspaper.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white.opacity(0.5))
                    )
                }
            }
            .frame(height: AppConstants.carouselHeight)
            .clipped()

            // Dark gradient overlay
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.25),
                    .init(color: .black.opacity(0.8), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // "Trending" badge on first article
            if index == 0 {
                VStack {
                    HStack {
                        Spacer()
                        Text("Trending")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.primaryOrange)
                            .clipShape(Capsule())
                            .padding(12)
                    }
                    Spacer()
                }
            }

            // Headline + source
            VStack(alignment: .leading, spacing: 4) {
                Text(article.laymanHeadline)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .shadow(radius: 2)

                HStack(spacing: 8) {
                    if let source = article.sourceName {
                        Text(source)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Text(article.readingTime)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadiusCard))
        .padding(.horizontal, AppConstants.standardPadding)
    }
}

// UI polish

// UI polish
