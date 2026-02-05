import SwiftUI
import DesignSystem

struct OnboardingIndex: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: OnboardingViewModel

    // MARK: - Body

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(viewModel.pages.indices, id: \.self) { index in
                Circle()
                    .frame(width: size(index))
                    .foregroundColor(color(index))
                    .accessibilityIdentifier(OnboardingAccessibilityIdentifiers.pageIndicator(index))
            }
        }
        .animation(DesignSystem.Animation.quickInteraction, value: viewModel.currentPage)
        .padding(padding)
        .fixedSize()
    }
}

// MARK: - Private Methods

private extension OnboardingIndex {
    var spacing: CGFloat { isIPad ? DesignSystem.Spacing.medium : DesignSystem.Spacing.small }
    var padding: CGFloat { isIPad ? DesignSystem.Spacing.extraExtraLarge : DesignSystem.Spacing.extraLarge }

    func size(_ index: Int) -> CGFloat {
        if index == viewModel.currentPage {
            isIPad ? DesignSystem.Radius.extraLarge : DesignSystem.Radius.medium
        } else {
            isIPad ? DesignSystem.Radius.medium : DesignSystem.Spacing.small
        }
    }

    func color(_ index: Int) -> Color {
        index == viewModel.currentPage ? DesignSystem.Color.onboardingIndicatorActive : DesignSystem.Color.onboardingIndicatorInactive
    }
}

#Preview {
    OnboardingIndex()
        .environmentObject(OnboardingViewModel())
}
