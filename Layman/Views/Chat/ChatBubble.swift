import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage
    @State private var isVisible = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 50)
            } else {
                // Bot icon
                Circle()
                    .fill(Color.primaryOrange)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text("L")
                            .font(.system(size: 14, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                    )
            }

            Text(message.content)
                .font(.system(size: 15))
                .foregroundColor(message.isUser ? .white : .textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(message.isUser ? Color.chatUserBubble : Color.chatBotBubble)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: message.isUser ? 18 : 4,
                        bottomLeadingRadius: 18,
                        bottomTrailingRadius: message.isUser ? 4 : 18,
                        topTrailingRadius: 18
                    )
                )

            if !message.isUser {
                Spacer(minLength: 50)
            }
        }
        .padding(.horizontal, 16)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 12)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                isVisible = true
            }
        }
    }
}

// UI polish

// UI polish

// Refactoring
