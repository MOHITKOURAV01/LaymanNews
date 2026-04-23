import SwiftUI
import UIKit

struct WelcomeView: View {
    @Binding var hasSeenWelcome: Bool
    @State private var logoVisible = false
    @State private var sloganVisible = false
    @State private var sliderOffset: CGFloat = 0
    @State private var sliderWidth: CGFloat = 0
    @State private var isPulsing = true

    private let thumbSize: CGFloat = 56
    private let trackHeight: CGFloat = 60

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.gradientStart, .gradientEnd],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo
                Text("Layman")
                    .font(.system(size: 44, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .opacity(logoVisible ? 1 : 0)

                Spacer().frame(height: 40)

                // Slogan
                VStack(spacing: 6) {
                    Text("Business, tech & startups")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text("made simple")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primaryOrange)
                }
                .offset(y: sloganVisible ? 0 : 30)
                .opacity(sloganVisible ? 1 : 0)

                Spacer()
                Spacer()

                // Swipe slider
                GeometryReader { geo in
                    let trackWidth = geo.size.width - 48
                    let maxOffset = trackWidth - thumbSize - 4

                    ZStack(alignment: .leading) {
                        // Track
                        RoundedRectangle(cornerRadius: trackHeight / 2)
                            .fill(Color.white.opacity(0.25))
                            .frame(height: trackHeight)

                        // Label
                        Text("Swipe to get started")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)

                        // Thumb
                        Circle()
                            .fill(Color.white)
                            .frame(width: thumbSize, height: thumbSize)
                            .overlay(
                                Image(systemName: "chevron.right.2")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primaryOrange)
                                    .scaleEffect(isPulsing ? 1.0 : 1.15)
                            )
                            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                            .offset(x: 2 + sliderOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        isPulsing = false
                                        sliderOffset = min(max(0, value.translation.width), maxOffset)
                                    }
                                    .onEnded { _ in
                                        if sliderOffset > maxOffset * 0.7 {
                                            let generator = UINotificationFeedbackGenerator()
                                            generator.notificationOccurred(.success)
                                            withAnimation(.easeOut(duration: 0.2)) {
                                                sliderOffset = maxOffset
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                hasSeenWelcome = true
                                            }
                                        } else {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                sliderOffset = 0
                                                isPulsing = true
                                            }
                                        }
                                    }
                            )
                    }
                    .padding(.horizontal, 24)
                    .onAppear { sliderWidth = trackWidth }
                }
                .frame(height: trackHeight)

                Spacer().frame(height: 60)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                logoVisible = true
            }
            withAnimation(.easeOut(duration: 0.7).delay(0.3)) {
                sloganVisible = true
            }
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isPulsing.toggle()
            }
        }
        .preferredColorScheme(.dark)
    }
}

// UI polish

// UI polish

// Refactoring
