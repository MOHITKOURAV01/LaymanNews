import Foundation
import SwiftUI

/// Manages user profile data from Supabase auth.
@Observable
final class ProfileViewModel {
    var userEmail: String = ""

    func loadProfile() {
        userEmail = SupabaseService.shared.getCurrentUserEmail() ?? "Not signed in"
    }
}
