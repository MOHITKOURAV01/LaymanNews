# CLAUDE.md — AI Development Context for Layman

This file provides project-specific context to the AI coding assistant used during development. It was used with **Antigravity** (Google DeepMind) as the primary AI-assisted development environment.

---

## Project Overview

Layman is a simplified iOS news reader covering business, tech, and startups. The core idea is to take complex news and present it in plain, everyday language — in layman's terms. The app is built entirely in SwiftUI using an MVVM architecture.

---

## Tech Stack

- **UI Framework:** SwiftUI (iOS 17+)
- **Architecture:** MVVM with `@Observable` ViewModels
- **Authentication & Database:** Supabase (Email/Password Auth + PostgreSQL with Row Level Security)
- **News Source:** NewsData.io API (business and technology categories)
- **AI Engine:** Groq API (LLaMA 3.1 8B Instant) for chat, content card generation, and question suggestions
- **Voice Input:** Apple Speech Framework (SFSpeechRecognizer + AVAudioEngine)
- **Package Manager:** Swift Package Manager
- **Primary Dependency:** supabase-swift

---

## Architecture Guidelines

### MVVM Pattern
- All ViewModels use the `@Observable` macro (Swift Observation framework)
- ViewModels are injected into views as `@State` properties
- Business logic lives in ViewModels and Services, never in Views
- Views are purely declarative UI

### State Management
- `@AppStorage` for persistent user preferences (dark mode, reading streak, articles read count)
- `@State` for local view state
- `@Observable` ViewModels for shared business state
- Supabase for cloud-synced data (saved articles, auth)

### Service Layer
- `SupabaseService` — Authentication (sign up, sign in, sign out, session restore) and saved articles CRUD
- `NewsService` — NewsData.io API client with pagination support
- `GroqService` — Groq AI integration for chat responses, content card generation, and auto-generated question suggestions
- `SpeechService` — Real-time speech-to-text using Apple's Speech framework

---

## Design System

### Color Palette
- **Primary Orange:** Accent color used for buttons, highlights, and interactive elements
- **Gradient Start/End:** Warm peach-to-orange gradient for the Welcome screen
- **Background:** Cream/beige for light mode, deep black for dark mode
- **Card Backgrounds:** Soft peach tint in light mode, dark gray in dark mode
- **Text Primary/Secondary:** Adaptive colors that switch between light and dark themes

### Typography
- Serif font for the "Layman" logo (`.system(.serif)`)
- System font for all body text and headings
- Headlines capped at approximately 50 characters for casual readability

### Layout Rules
- Featured carousel uses full-bleed images with bottom gradient overlays for text readability
- Article rows use rounded thumbnails on the left with headline text on the right
- Content cards contain 28-35 words each (2 sentences), filling approximately 6 lines
- Tab bar has 3 tabs: Home, Saved, Profile

---

## API Configuration

All API keys are loaded securely through the `Secrets.xcconfig` > `Info.plist` > `Bundle.main.infoDictionary` chain. Keys are never hardcoded.

Required keys:
- `SUPABASE_URL` — Supabase project URL
- `SUPABASE_ANON_KEY` — Supabase anonymous key
- `NEWS_API_KEY` — NewsData.io API key
- `GROQ_API_KEY` — Groq API key

The `Secrets.xcconfig` file is listed in `.gitignore` and must be created locally.

---

## Key Implementation Details

### Article Content Cards
- Each article generates 3 swipeable content cards via the Groq API
- Each card contains exactly 2 sentences (28-35 words) written in layman's terms
- If the AI call fails, static fallback cards are generated from the article's raw content
- Cards use 3D rotation animations during swipe transitions

### Ask Layman Chatbot
- Context-aware: receives the full article context in the system prompt
- Responses are limited to 1-2 sentences in simple, everyday language
- 3 auto-generated question suggestions are created per article
- Voice input is functional via SpeechService (requires physical device)

### Headline Generation
- `Article.laymanHeadline` generates simplified headlines
- Maximum 48-52 characters (7-9 words)
- Conversational and casual tone, not formal news-speak

### Saved Articles
- Synced to Supabase with Row Level Security (users can only access their own data)
- Swipe-to-delete with animated feedback
- Real-time bookmark state tracking across views

### Reading Streaks
- Tracked per unique article read (not per app open)
- Consecutive day tracking with automatic reset if a day is missed
- Displayed as a flame badge in the Home header and Profile stats

### Dark Mode
- Full adaptive color system across all screens
- Manual toggle in Profile settings
- All components (cards, backgrounds, text, tab bar) adapt automatically

---

## File Structure

```
Layman/
├── LaymanApp.swift                     # App entry point, auth state routing
├── Config/
│   └── AppConfig.swift                 # Loads API keys from Info.plist
├── Models/
│   ├── Article.swift                   # News article model + layman headline
│   ├── ChatMessage.swift               # Chat message model
│   └── SavedArticle.swift              # Supabase saved article models
├── ViewModels/
│   ├── AuthViewModel.swift             # Auth state management
│   ├── ArticlesViewModel.swift         # News feed, pagination, search
│   ├── ChatViewModel.swift             # Chat UI state + Groq integration
│   ├── SavedViewModel.swift            # Saved articles + Supabase sync
│   └── ProfileViewModel.swift          # User profile state
├── Views/
│   ├── WelcomeView.swift               # Onboarding with swipe-to-start
│   ├── AuthView.swift                  # Login / Sign-up
│   ├── MainTabView.swift               # Tab navigation
│   ├── Home/                           # Home feed views
│   ├── Detail/                         # Article detail + content cards
│   ├── Chat/                           # AI chatbot views
│   ├── Saved/                          # Bookmarked articles
│   └── Profile/                        # User profile and settings
├── Services/
│   ├── SupabaseService.swift           # Auth + saved articles CRUD
│   ├── NewsService.swift               # NewsData.io API client
│   ├── GroqService.swift               # Groq AI integration
│   └── SpeechService.swift             # Speech-to-text
└── Utilities/
    ├── Constants.swift                 # Color palette, design tokens
    └── Extensions.swift                # View helpers
```

---

## Testing Notes

- Voice input (SpeechService) requires a physical iOS device and will not function in the Simulator
- The `hasSeenWelcome` flag in UserDefaults must be reset (or the app reinstalled) to re-test the onboarding flow
- Supabase email confirmation should be disabled in the dashboard for development testing
- Use `https:/$()/` syntax in xcconfig files to prevent `//` from being interpreted as comments

---

## AI Tool Used

**Antigravity** (Google DeepMind) — Used as the primary AI coding assistant for architecture design, API integrations, SwiftUI view composition, debugging, and iterative development.
