import SwiftUI

struct TextView: View {
    // MARK: - Properties

    let text: String
    let isPercent: Bool
    var accessibilityId: String?

    // MARK: - Body

    var body: some View {
        Text(text)
            .padding(textPadding)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: frameHeight, maxHeight: frameHeight)
            .background(Color(uiColor: .secondarySystemFill))
            .cornerRadius(cornerRadius)
            .foregroundColor(color)
            .accessibilityIdentifier(accessibilityId ?? "")
    }
}

// MARK: - Private Computed Properties

private extension TextView {
    var textPadding: CGFloat { AppConstants.Padding.small }
    var frameHeight: CGFloat {
        isIPad ? AppConstants.Heights.regular : AppConstants.Heights.compact
    }
    var cornerRadius: CGFloat {
        isIPad ? AppConstants.CornerRadius.large : AppConstants.CornerRadius.small
    }
    var color: Color { text.isNumberNotNegative() ? .green : .red }
}

#Preview {
    TextView(text: 1.formatToString(isPercent: true), isPercent: true)
        .padding()
}
