import SwiftUI
import SafariServices

struct WebViewSheet: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        SafariView(url: url)
            .ignoresSafeArea()
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let safari = SFSafariViewController(url: url, configuration: config)
        safari.preferredControlTintColor = UIColor(Color.primaryOrange)
        return safari
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
