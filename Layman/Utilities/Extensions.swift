import SwiftUI
import UIKit

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func cardStyle() -> some View {
        self
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadiusCard))
    }

    func primaryButtonStyle() -> some View {
        self
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.primaryOrange)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadiusButton))
    }
}

extension Font {
    static let laymanLogo = Font.system(size: 32, weight: .bold, design: .serif)
    static let sectionHeader = Font.system(size: 20, weight: .bold)
    static let articleHeadline = Font.system(size: 16, weight: .semibold)
    static let cardBody = Font.system(size: 15, weight: .regular)
    static let tabLabel = Font.system(size: 10, weight: .medium)
}
