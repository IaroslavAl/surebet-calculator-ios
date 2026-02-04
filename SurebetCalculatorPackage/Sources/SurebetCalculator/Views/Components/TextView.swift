import SwiftUI

struct TextView: View {
    // MARK: - Properties

    let text: String
    let isPercent: Bool
    let isEmphasized: Bool
    var accessibilityId: String?

    // MARK: - Body

    var body: some View {
        Text(text)
            .font(AppConstants.Typography.numeric)
            .padding(textPadding)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: frameHeight, maxHeight: frameHeight)
            .background(AppColors.surfaceResult)
            .cornerRadius(cornerRadius)
            .foregroundColor(color)
            .overlay {
                if isEmphasized {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(AppColors.border, lineWidth: 1)
                }
            }
            .accessibilityIdentifier(accessibilityId ?? "")
    }
}

// MARK: - Private Computed Properties

private extension TextView {
    var textPadding: CGFloat {
        isIPad ? AppConstants.Padding.large : AppConstants.Padding.small
    }
    var frameHeight: CGFloat {
        isIPad ? AppConstants.Heights.regular : AppConstants.Heights.compact
    }
    var cornerRadius: CGFloat {
        isIPad ? AppConstants.CornerRadius.large : AppConstants.CornerRadius.small
    }
    var color: Color { text.isNumberNotNegative() ? AppColors.success : AppColors.error }
}

#Preview {
    TextView(text: 1.formatToString(isPercent: true), isPercent: true, isEmphasized: false)
        .padding()
}
