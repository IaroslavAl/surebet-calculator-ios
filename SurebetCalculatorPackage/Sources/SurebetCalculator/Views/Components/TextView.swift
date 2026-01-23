import SwiftUI

struct TextView: View {
    // MARK: - Properties

    let text: String
    let isPercent: Bool

    // MARK: - Body

    var body: some View {
        Text(text)
            .padding(textPadding)
            .frame(height: frameHeight)
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemFill))
            .cornerRadius(cornerRadius)
            .foregroundColor(color)
    }
}

// MARK: - Private Computed Properties

private extension TextView {
    var textPadding: CGFloat { AppConstants.Layout.Padding.small }
    var frameHeight: CGFloat {
        isIPad ? AppConstants.Layout.Heights.regular : AppConstants.Layout.Heights.compact
    }
    var cornerRadius: CGFloat {
        isIPad ? AppConstants.Layout.CornerRadius.large : AppConstants.Layout.CornerRadius.small
    }
    var color: Color { text.isNumberNotNegative() ? .green : .red }
}

#Preview {
    TextView(text: 1.formatToString(isPercent: true), isPercent: true)
        .padding()
}
