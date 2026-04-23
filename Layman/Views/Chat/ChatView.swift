import SwiftUI
import UIKit

struct ChatView: View {
    @State private var viewModel: ChatViewModel
    @State private var speechService = SpeechService()
    @Environment(\.dismiss) private var dismiss

    init(articleTitle: String, articleContent: String) {
        _viewModel = State(initialValue: ChatViewModel(
            articleTitle: articleTitle,
            articleContent: articleContent
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }

                        // Suggestion chips
                        if viewModel.showSuggestions && !viewModel.suggestions.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(viewModel.suggestions, id: \.self) { suggestion in
                                    SuggestionChip(text: suggestion) {
                                        viewModel.selectSuggestion(suggestion)
                                    }
                                }
                            }
                            .padding(.leading, 52)
                            .padding(.trailing, 16)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }

                        // Typing indicator
                        if viewModel.isLoading {
                            TypingIndicator()
                                .id("typing")
                        }
                    }
                    .padding(.vertical, 12)
                }
                .onChange(of: viewModel.messages.count) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        if let last = viewModel.messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.isLoading) {
                    if viewModel.isLoading {
                        withAnimation { proxy.scrollTo("typing", anchor: .bottom) }
                    }
                }
            }

            Divider().opacity(0.5)

            // Input bar
            HStack(spacing: 8) {
                TextField(
                    speechService.isRecording ? "Listening..." : "Type your question...",
                    text: $viewModel.inputText
                )
                    .font(.system(size: 15))
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.searchBarBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(speechService.isRecording ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1.5)
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .disabled(speechService.isRecording)
                    .onSubmit {
                        Task { await viewModel.sendMessage() }
                    }

                // Mic button
                Button {
                    if !speechService.permissionGranted {
                        speechService.requestPermission { granted in
                            if granted {
                                speechService.startRecording()
                            }
                        }
                    } else {
                        speechService.toggleRecording()
                    }
                } label: {
                    ZStack {
                        Image(systemName: speechService.isRecording ? "mic.fill" : "mic")
                            .font(.system(size: 18))
                            .foregroundColor(speechService.isRecording ? .white : .textSecondary)
                            .frame(width: 36, height: 36)
                            .background(speechService.isRecording ? Color.red : Color.clear)
                            .clipShape(Circle())
                            .scaleEffect(speechService.isRecording ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: speechService.isRecording)
                    }
                }

                // Send button
                Button {
                    Task { await viewModel.sendMessage() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 34))
                        .foregroundColor(
                            viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty
                            ? .tabInactive
                            : .primaryOrange
                        )
                }
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty || speechService.isRecording)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.appBackground)
        }
        .background(Color.appBackground)
        .navigationTitle("Ask Layman")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primaryOrange)
            }
        }
        .task {
            await viewModel.loadSuggestions()
            speechService.requestPermission()
        }
        .onChange(of: speechService.transcript) {
            if !speechService.transcript.isEmpty {
                viewModel.inputText = speechService.transcript
            }
        }
        .onChange(of: speechService.isRecording) {
            // When recording stops, auto-send if we have transcript
            if !speechService.isRecording && !speechService.transcript.isEmpty {
                viewModel.inputText = speechService.transcript
                Task { await viewModel.sendMessage() }
                speechService.transcript = ""
            }
        }
        .onTapGesture { hideKeyboard() }
        .alert("Permission Required", isPresented: $speechService.showPermissionAlert) {
            Button("OK") {}
        } message: {
            Text(speechService.errorMessage ?? "Microphone and speech recognition permissions are needed for voice input.")
        }
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var dot1 = false
    @State private var dot2 = false
    @State private var dot3 = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.primaryOrange)
                .frame(width: 28, height: 28)
                .overlay(
                    Text("L")
                        .font(.system(size: 14, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                )

            HStack(spacing: 5) {
                Circle().fill(Color.textSecondary.opacity(0.6)).frame(width: 7, height: 7).offset(y: dot1 ? -4 : 0)
                Circle().fill(Color.textSecondary.opacity(0.6)).frame(width: 7, height: 7).offset(y: dot2 ? -4 : 0)
                Circle().fill(Color.textSecondary.opacity(0.6)).frame(width: 7, height: 7).offset(y: dot3 ? -4 : 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.chatBotBubble)
            .clipShape(RoundedRectangle(cornerRadius: 18))

            Spacer()
        }
        .padding(.horizontal, 16)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.45).repeatForever(autoreverses: true)) { dot1 = true }
            withAnimation(.easeInOut(duration: 0.45).repeatForever(autoreverses: true).delay(0.15)) { dot2 = true }
            withAnimation(.easeInOut(duration: 0.45).repeatForever(autoreverses: true).delay(0.3)) { dot3 = true }
        }
    }
}

// UI polish

// UI polish

// Refactoring
