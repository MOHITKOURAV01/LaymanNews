import SwiftUI

struct SuggestionChip: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primaryOrange)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.suggestionChip)
                .overlay(
                    Capsule()
                        .stroke(Color.primaryOrange, lineWidth: 1)
                )
                .clipShape(Capsule())
        }
    }
}
