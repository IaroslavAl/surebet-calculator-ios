import SwiftUI
import DesignSystem
import UIKit

struct NavigationClearButton: View {
    // MARK: - Properties

    @Environment(\.locale) private var locale
    let onClear: () -> Void

    // MARK: - Body

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onClear()
        } label: {
            Image(systemName: "trash")
                .font(font)
                .foregroundColor(DesignSystem.Color.textSecondary)
                .accessibilityLabel(SurebetCalculatorLocalizationKey.clearAll.localized(locale))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(AccessibilityIdentifiers.Calculator.clearButton)
    }

    var font: Font {
        isIPad ? .body : .callout
    }

}

#Preview {
    NavigationClearButton(onClear: {})
}
