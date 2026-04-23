import SwiftUI
import UIKit
import PhotosUI
import StoreKit

struct ProfileView: View {
    @Bindable var authVM: AuthViewModel
    @State private var profileVM = ProfileViewModel()
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("readingStreak") private var readingStreak = 0
    @AppStorage("articlesReadCount") private var articlesReadCount = 0
    @AppStorage("lastReadDate") private var lastReadDate: Double = 0
    @AppStorage("userName") private var userName = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @State private var showSignOutAlert = false
    @State private var showClearCacheAlert = false
    @State private var showCacheClearedToast = false
    @State private var isEditingName = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImageData: Data?

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer().frame(height: 20)

                    // Avatar with photo picker
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        ZStack(alignment: .bottomTrailing) {
                            if let data = profileImageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 90, height: 90)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.gradientStart, .gradientEnd],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 90, height: 90)
                                    .overlay(
                                        Text(avatarInitial)
                                            .font(.system(size: 36, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                            }

                            // Camera badge
                            Circle()
                                .fill(Color.primaryOrange)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 2, y: 2)
                        }
                        .shadow(color: Color.primaryOrange.opacity(0.2), radius: 8, y: 4)
                    }

                    // Name (editable)
                    if isEditingName {
                        TextField("Your name", text: $userName)
                            .font(.system(size: 20, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 40)
                            .onSubmit { isEditingName = false }
                    } else {
                        Button {
                            isEditingName = true
                        } label: {
                            HStack(spacing: 4) {
                                Text(userName.isEmpty ? "Tap to add name" : userName)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(userName.isEmpty ? .textSecondary : .textPrimary)
                                Image(systemName: "pencil")
                                    .font(.system(size: 12))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }

                    // Email
                    Text(profileVM.userEmail)
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)

                    // Reading streak + stats
                    HStack(spacing: 16) {
                        statBadge(icon: "flame.fill", value: "\(readingStreak)", label: "Day Streak")
                        statBadge(icon: "book.fill", value: "\(articlesReadCount)", label: "Articles Read")
                    }
                    .padding(.horizontal, AppConstants.standardPadding)

                    // App Settings section
                    sectionCard(title: "App Settings") {
                        settingsRow(
                            icon: darkModeEnabled ? "moon.fill" : "sun.max.fill",
                            title: "Dark Mode",
                            iconRotation: darkModeEnabled ? 0 : 180
                        ) {
                            Toggle("", isOn: $darkModeEnabled)
                                .tint(.primaryOrange)
                                .onChange(of: darkModeEnabled) {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                }
                        }
                        Divider().padding(.leading, 50)
                        settingsRow(icon: "bell.fill", title: "Notifications") {
                            Toggle("", isOn: $notificationsEnabled)
                                .tint(.primaryOrange)
                                .onChange(of: notificationsEnabled) {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                }
                        }
                        Divider().padding(.leading, 50)
                        Button {
                            clearAllCache()
                        } label: {
                            settingsRow(icon: "trash.fill", title: "Clear Cache") {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    // Support section
                    sectionCard(title: "Support") {
                        Button {
                            requestAppReview()
                        } label: {
                            supportRow(icon: "star.fill", title: "Rate App")
                        }
                        .buttonStyle(.plain)
                        Divider().padding(.leading, 50)
                        ShareLink(item: URL(string: "https://apps.apple.com/app/layman")!) {
                            supportRow(icon: "square.and.arrow.up", title: "Share App")
                        }
                        .buttonStyle(.plain)
                        Divider().padding(.leading, 50)
                        Button {
                            openMail()
                        } label: {
                            supportRow(icon: "envelope.fill", title: "Contact Us")
                        }
                        .buttonStyle(.plain)
                        Divider().padding(.leading, 50)
                        Button {
                            openPrivacyPolicy()
                        } label: {
                            supportRow(icon: "lock.shield.fill", title: "Privacy Policy")
                        }
                        .buttonStyle(.plain)
                    }

                    // Sign out
                    Button { showSignOutAlert = true } label: {
                        Text("Sign Out")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryOrange)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppConstants.cornerRadiusButton)
                                    .stroke(Color.primaryOrange, lineWidth: 2)
                            )
                    }
                    .padding(.horizontal, AppConstants.standardPadding)

                    Text("Layman v1.0")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)

                    Spacer().frame(height: 40)
                }
            }
        }
        .preferredColorScheme(darkModeEnabled ? .dark : .light)
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                Task { await authVM.signOut() }
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Clear Cache", isPresented: $showClearCacheAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                performClearCache()
            }
        } message: {
            Text("This will clear cached articles and reset articles read count. Your streak will not be affected.")
        }
        .overlay(alignment: .bottom) {
            if showCacheClearedToast {
                Text("Cache cleared!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.textPrimary.opacity(0.9))
                    .clipShape(Capsule())
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            profileVM.loadProfile()
            loadProfileImage()
        }
        .onChange(of: selectedPhoto) {
            Task { await handlePhotoSelection() }
        }
        .onTapGesture { hideKeyboard() }
    }

    // MARK: - Photo

    private func handlePhotoSelection() async {
        guard let item = selectedPhoto else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        // Compress to JPEG
        if let uiImage = UIImage(data: data),
           let compressed = uiImage.jpegData(compressionQuality: 0.5) {
            profileImageData = compressed
            UserDefaults.standard.set(compressed, forKey: "profilePhoto")
        }
    }

    private func loadProfileImage() {
        profileImageData = UserDefaults.standard.data(forKey: "profilePhoto")
    }

    // MARK: - Helpers

    private var avatarInitial: String {
        let name = userName.isEmpty ? profileVM.userEmail : userName
        let initial = String(name.prefix(1)).uppercased()
        return initial.isEmpty ? "?" : initial
    }

    @ViewBuilder
    private func statBadge(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.primaryOrange)
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.textPrimary)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadiusCard))
    }

    @ViewBuilder
    private func sectionCard(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal, AppConstants.standardPadding)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.cardWhite)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadiusCard))
            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
            .padding(.horizontal, AppConstants.standardPadding)
        }
    }

    @ViewBuilder
    private func settingsRow<Content: View>(icon: String, title: String, iconRotation: Double = 0, @ViewBuilder trailing: () -> Content) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.primaryOrange)
                .frame(width: 28)
                .rotationEffect(.degrees(iconRotation))
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: iconRotation)
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.textPrimary)
            Spacer()
            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Actions

    private func clearAllCache() {
        showClearCacheAlert = true
    }

    private func performClearCache() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // Clear cached articles
        UserDefaults.standard.removeObject(forKey: "cachedArticles")
        // Reset articles read count + read IDs (but keep streak intact)
        articlesReadCount = 0
        UserDefaults.standard.removeObject(forKey: "readArticleIds")

        withAnimation { showCacheClearedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showCacheClearedToast = false }
        }
    }

    private func requestAppReview() {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }

    private func openMail() {
        if let url = URL(string: "mailto:team@thebrewapps.com?subject=Layman%20App%20Feedback") {
            UIApplication.shared.open(url)
        }
    }

    private func openPrivacyPolicy() {
        if let url = URL(string: "https://www.thebrewapps.com/privacy") {
            UIApplication.shared.open(url)
        }
    }

    @ViewBuilder
    private func supportRow(icon: String, title: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.primaryOrange)
                .frame(width: 28)
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// UI polish

// UI polish

// UI polish

// UI polish

// Refactoring

// Refactoring
