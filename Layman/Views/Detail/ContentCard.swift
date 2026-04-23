import SwiftUI

struct ContentCard: View {
    let text: String
    @Environment(\.colorScheme) private var colorScheme
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 0) {
            // Left orange accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.primaryOrange)
                .frame(width: 3.5)
                .padding(.vertical, 16)

            // Content text
            Text(text)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.textPrimary)
                .lineLimit(6)
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding(.trailing, 20)
                .padding(.vertical, 20)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.5), value: appeared)
        }
        .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 180)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(cardBorder, lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 8, y: 4)
        .onAppear { appeared = true }
        .onDisappear { appeared = false }
    }

    private var cardGradient: LinearGradient {
        if colorScheme == .dark {
            LinearGradient(
                colors: [Color(hex: "2C2C2E"), Color(hex: "1F1F21")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            LinearGradient(
                colors: [Color.cardWhite, Color.cardBackground.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var cardBorder: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.1)
            : Color.primaryOrange.opacity(0.08)
    }
}

// UI polish

// UI polish

// Refactoring
