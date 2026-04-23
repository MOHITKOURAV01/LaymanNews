import Foundation

nonisolated enum AppConfig {
    static var supabaseURL: String {
        guard let value = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String,
              !value.isEmpty, value != "your_supabase_url_here" else {
            fatalError("SUPABASE_URL not configured in Secrets.xcconfig")
        }
        return value
    }

    static var supabaseAnonKey: String {
        guard let value = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String,
              !value.isEmpty, value != "your_supabase_anon_key_here" else {
            fatalError("SUPABASE_ANON_KEY not configured in Secrets.xcconfig")
        }
        return value
    }

    static var newsAPIKey: String {
        guard let value = Bundle.main.infoDictionary?["NEWS_API_KEY"] as? String,
              !value.isEmpty, value != "your_newsdata_api_key_here" else {
            fatalError("NEWS_API_KEY not configured in Secrets.xcconfig")
        }
        return value
    }

    static var groqAPIKey: String {
        guard let value = Bundle.main.infoDictionary?["GROQ_API_KEY"] as? String,
              !value.isEmpty, value != "YOUR_GROQ_KEY_HERE" else {
            fatalError("GROQ_API_KEY not configured in Secrets.xcconfig")
        }
        return value
    }
}
