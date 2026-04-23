import SwiftUI

struct AuthView: View {
    @Bindable var authVM: AuthViewModel

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 40)

                    // Logo
                    Text("Layman")
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .foregroundColor(.textPrimary)

                    // Subtitle
                    Text(authVM.isSignUp ? "Create account" : "Welcome back")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.textSecondary)

                    Spacer().frame(height: 8)

                    // Fields
                    VStack(spacing: 14) {
                        TextField("Email", text: $authVM.email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding(14)
                            .background(Color.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        SecureField("Password", text: $authVM.password)
                            .textContentType(authVM.isSignUp ? .newPassword : .password)
                            .padding(14)
                            .background(Color.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        if authVM.isSignUp {
                            SecureField("Confirm Password", text: $authVM.confirmPassword)
                                .textContentType(.newPassword)
                                .padding(14)
                                .background(Color.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.horizontal, 24)

                    // Error
                    if let error = authVM.errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    // Button
                    Button {
                        Task {
                            if authVM.isSignUp {
                                await authVM.signUp()
                            } else {
                                await authVM.signIn()
                            }
                        }
                    } label: {
                        Text(authVM.isSignUp ? "Sign Up" : "Sign In")
                            .primaryButtonStyle()
                    }
                    .padding(.horizontal, 24)
                    .scaleEffect(authVM.isLoading ? 0.95 : 1.0)

                    // Toggle
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            authVM.isSignUp.toggle()
                            authVM.errorMessage = nil
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(authVM.isSignUp ? "Already have an account?" : "Don't have an account?")
                                .foregroundColor(.textSecondary)
                            Text(authVM.isSignUp ? "Sign In" : "Sign Up")
                                .foregroundColor(.primaryOrange)
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 14))
                    }

                    Spacer()
                }
            }
            .scrollDismissesKeyboard(.interactively)

            if authVM.isLoading {
                Color.black.opacity(0.2).ignoresSafeArea()
                ProgressView()
                    .tint(.primaryOrange)
                    .scaleEffect(1.3)
            }
        }
        .onTapGesture { hideKeyboard() }
    }
}
