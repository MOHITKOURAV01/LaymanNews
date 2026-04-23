import SwiftUI

struct ArticleRow: View {
    let article: Article

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
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
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 22))
                    )
                }
            }
            .frame(width: AppConstants.thumbnailSize, height: AppConstants.thumbnailSize)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadiusThumbnail))

            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(article.laymanHeadline)
                    .font(.articleHeadline)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 6) {
                    if let source = article.sourceName {
                        Text(source)
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                    }
                    Text("·")
                        .foregroundColor(.textSecondary)
                    Text(article.readingTime)
                        .font(.system(size: 11))
                        .foregroundColor(.textSecondary)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.tabInactive)
        }
        .padding(12)
        .background(Color.cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadiusThumbnail))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}
