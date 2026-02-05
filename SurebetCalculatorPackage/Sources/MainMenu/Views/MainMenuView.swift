import SurebetCalculator
import SwiftUI
import DesignSystem

struct MainMenuView: View {
    // MARK: - Properties

    let calculatorAnalytics: CalculatorAnalytics

    // MARK: - Body

    var body: some View {
        let layout = MenuLayout.regular
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: sectionSpacing(layout)) {
                    header()
                    calculatorAction(layout)
                    secondaryActions(layout)
                }
                .padding(.horizontal, horizontalPadding(layout))
                .padding(.vertical, verticalPadding(layout))
            }
        }
        .navigationTitle(menuNavigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Private Computed Properties

private extension MainMenuView {
    var menuNavigationTitle: String { MainMenuLocalizationKey.menuNavigationTitle.localized }
    var menuTitle: String { MainMenuLocalizationKey.menuTitle.localized }
    var menuSubtitle: String { MainMenuLocalizationKey.menuSubtitle.localized }
    var menuCalculatorTitle: String { MainMenuLocalizationKey.menuCalculatorTitle.localized }
    var menuCalculatorSubtitle: String { MainMenuLocalizationKey.menuCalculatorSubtitle.localized }
    var menuSettingsTitle: String { MainMenuLocalizationKey.menuSettingsTitle.localized }
    var menuSettingsSubtitle: String { MainMenuLocalizationKey.menuSettingsSubtitle.localized }
    var menuInstructionsTitle: String { MainMenuLocalizationKey.menuInstructionsTitle.localized }
    var menuInstructionsSubtitle: String { MainMenuLocalizationKey.menuInstructionsSubtitle.localized }
    var menuFeedbackTitle: String { MainMenuLocalizationKey.menuFeedbackTitle.localized }
    var menuFeedbackSubtitle: String { MainMenuLocalizationKey.menuFeedbackSubtitle.localized }
    var menuDisableAdsTitle: String { MainMenuLocalizationKey.menuDisableAdsTitle.localized }
    var menuDisableAdsSubtitle: String { MainMenuLocalizationKey.menuDisableAdsSubtitle.localized }

    func header() -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text(menuTitle)
                .font(DesignSystem.Typography.title)
                .foregroundColor(DesignSystem.Color.textPrimary)
            Text(menuSubtitle)
                .font(DesignSystem.Typography.description)
                .foregroundColor(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func calculatorAction(_ layout: MenuLayout) -> some View {
        MenuCardLink(
            title: menuCalculatorTitle,
            subtitle: menuCalculatorSubtitle,
            systemImage: "calculator",
            style: .primary,
            layout: layout,
            showsSubtitle: layout.showsPrimarySubtitle
        ) {
            SurebetCalculator.view(analytics: calculatorAnalytics)
        }
    }

    func secondaryActions(_ layout: MenuLayout) -> some View {
        VStack(spacing: cardSpacing(layout)) {
            settingsAction(layout)
            instructionsAction(layout)
            feedbackAction(layout)
            disableAdsAction(layout)
        }
    }

    func settingsAction(_ layout: MenuLayout) -> some View {
        MenuCardLink(
            title: menuSettingsTitle,
            subtitle: menuSettingsSubtitle,
            systemImage: "slider.horizontal.3",
            style: .standard,
            layout: layout,
            showsSubtitle: layout.showsSecondarySubtitle
        ) {
            MenuPlaceholderView(
                title: menuSettingsTitle,
                message: MainMenuLocalizationKey.menuSettingsDescription.localized,
                systemImage: "gearshape"
            )
        }
    }

    func instructionsAction(_ layout: MenuLayout) -> some View {
        MenuCardLink(
            title: menuInstructionsTitle,
            subtitle: menuInstructionsSubtitle,
            systemImage: "book.closed",
            style: .standard,
            layout: layout,
            showsSubtitle: layout.showsSecondarySubtitle
        ) {
            MenuInstructionsView()
        }
    }

    func feedbackAction(_ layout: MenuLayout) -> some View {
        MenuCardLink(
            title: menuFeedbackTitle,
            subtitle: menuFeedbackSubtitle,
            systemImage: "envelope",
            style: .standard,
            layout: layout,
            showsSubtitle: layout.showsSecondarySubtitle
        ) {
            MenuPlaceholderView(
                title: menuFeedbackTitle,
                message: MainMenuLocalizationKey.menuFeedbackDescription.localized,
                systemImage: "bubble.left.and.bubble.right"
            )
        }
    }

    func disableAdsAction(_ layout: MenuLayout) -> some View {
        MenuCardLink(
            title: menuDisableAdsTitle,
            subtitle: menuDisableAdsSubtitle,
            systemImage: "cart",
            style: .highlight,
            layout: layout,
            showsSubtitle: layout.showsSecondarySubtitle
        ) {
            MenuPlaceholderView(
                title: menuDisableAdsTitle,
                message: MainMenuLocalizationKey.menuDisableAdsDescription.localized,
                systemImage: "nosign"
            )
        }
    }

    func sectionSpacing(_ layout: MenuLayout) -> CGFloat {
        switch layout {
        case .regular:
            return isIPad ? DesignSystem.Spacing.extraLarge : DesignSystem.Spacing.large
        case .compact:
            return isIPad ? DesignSystem.Spacing.large : DesignSystem.Spacing.medium
        case .ultraCompact:
            return isIPad ? DesignSystem.Spacing.medium : DesignSystem.Spacing.small
        }
    }

    func cardSpacing(_ layout: MenuLayout) -> CGFloat {
        switch layout {
        case .regular:
            return DesignSystem.Spacing.medium
        case .compact, .ultraCompact:
            return DesignSystem.Spacing.small
        }
    }

    func horizontalPadding(_ layout: MenuLayout) -> CGFloat {
        switch layout {
        case .regular, .compact:
            return DesignSystem.Spacing.large
        case .ultraCompact:
            return DesignSystem.Spacing.medium
        }
    }

    func verticalPadding(_ layout: MenuLayout) -> CGFloat {
        switch layout {
        case .regular:
            return isIPad ? DesignSystem.Spacing.extraLarge : DesignSystem.Spacing.large
        case .compact:
            return DesignSystem.Spacing.medium
        case .ultraCompact:
            return DesignSystem.Spacing.small
        }
    }

}

#Preview {
    NavigationStack {
        MainMenuView(calculatorAnalytics: NoopCalculatorAnalytics())
    }
}
