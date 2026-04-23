import Foundation
import SwiftUI
import Supabase

@Observable
@MainActor
final class AuthViewModel {
    var email = ""
    var password = ""
    var confirmPassword = ""
    var isLoading = false
    var errorMessage: String?
    var isAuthenticated = false
    var isSignUp = false
    var isCheckingSession = true

    /// Start listening to Supabase auth state changes. Call once on app launch.
    func startAuthListener() {
        Task {
            await checkExistingSession()
            isCheckingSession = false
        }

        Task {
            for await (event, session) in SupabaseService.shared.client.auth.authStateChanges {
                switch event {
                case .signedIn, .tokenRefreshed, .userUpdated, .initialSession:
                    isAuthenticated = session != nil
                case .signedOut:
                    isAuthenticated = false
                default:
                    break
                }
            }
        }
    }

    func signUp() async {
        guard validateInput() else { return }
        isLoading = true
        errorMessage = nil

        do {
            try await SupabaseService.shared.signUp(email: email, password: password)
            // Auto sign in right after sign up
            try await SupabaseService.shared.signIn(email: email, password: password)
            isAuthenticated = true
        } catch {
            let msg = error.localizedDescription
            // User already exists → just sign them in
            if msg.lowercased().contains("already") || msg.lowercased().contains("exists") || msg.lowercased().contains("registered") {
                do {
                    try await SupabaseService.shared.signIn(email: email, password: password)
                    isAuthenticated = true
                } catch {
                    errorMessage = "Account exists. Check your password."
                }
            } else {
                errorMessage = msg
            }
        }
        isLoading = false
    }

    func signIn() async {
        guard validateInput() else { return }
        isLoading = true
        errorMessage = nil

        do {
            try await SupabaseService.shared.signIn(email: email, password: password)
            isAuthenticated = true
        } catch {
            let msg = error.localizedDescription
            // User not found → auto sign up
            if msg.lowercased().contains("not found") || msg.lowercased().contains("invalid") || msg.lowercased().contains("no user") {
                errorMessage = "Invalid email or password. Try again or sign up."
            } else {
                errorMessage = msg
            }
        }
        isLoading = false
    }

    func checkExistingSession() async {
        do {
            _ = try await SupabaseService.shared.getSession()
            isAuthenticated = true
        } catch {
            isAuthenticated = false
        }
    }

    func signOut() async {
        do {
            try await SupabaseService.shared.signOut()
            isAuthenticated = false
            email = ""
            password = ""
            confirmPassword = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func validateInput() -> Bool {
        errorMessage = nil

        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please enter your email"
            return false
        }

        if !email.contains("@") || !email.contains(".") {
            errorMessage = "Please enter a valid email"
            return false
        }

        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            return false
        }

        if isSignUp && password != confirmPassword {
            errorMessage = "Passwords don't match"
            return false
        }

        return true
    }
}

// UI polish

// UI polish

// Refactoring
