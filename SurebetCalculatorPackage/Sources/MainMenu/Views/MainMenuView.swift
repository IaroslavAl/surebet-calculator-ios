import Foundation
import SwiftUI
import DesignSystem

struct MainMenuView: View {
    // MARK: - Properties

    let onRouteRequested: (MainMenuRoute) -> Void
    @Environment(\.locale) private var locale
    @Environment(\.openURL) private var openURL

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

private enum FeedbackMailConstants {
    static let emailAddress = "beldin.y.a@yandex.ru"
    static let mailtoScheme = "mailto"
    static let subjectQueryName = "subject"
    static let bundleDisplayNameKey = "CFBundleDisplayName"
    static let bundleNameKey = "CFBundleName"
}

// MARK: - Private Computed Properties

private extension MainMenuView {
    var menuNavigationTitle: String { MainMenuLocalizationKey.menuNavigationTitle.localized(locale) }
    var menuTitle: String { MainMenuLocalizationKey.menuTitle.localized(locale) }
    var menuSubtitle: String { MainMenuLocalizationKey.menuSubtitle.localized(locale) }
    var menuCalculatorTitle: String { MainMenuLocalizationKey.menuCalculatorTitle.localized(locale) }
    var menuCalculatorSubtitle: String { MainMenuLocalizationKey.menuCalculatorSubtitle.localized(locale) }
    var menuSettingsTitle: String { MainMenuLocalizationKey.menuSettingsTitle.localized(locale) }
    var menuSettingsSubtitle: String { MainMenuLocalizationKey.menuSettingsSubtitle.localized(locale) }
    var menuInstructionsTitle: String { MainMenuLocalizationKey.menuInstructionsTitle.localized(locale) }
    var menuInstructionsSubtitle: String { MainMenuLocalizationKey.menuInstructionsSubtitle.localized(locale) }
    var menuFeedbackTitle: String { MainMenuLocalizationKey.menuFeedbackTitle.localized(locale) }
    var menuFeedbackSubtitle: String { MainMenuLocalizationKey.menuFeedbackSubtitle.localized(locale) }
    var menuDisableAdsTitle: String { MainMenuLocalizationKey.menuDisableAdsTitle.localized(locale) }
    var menuDisableAdsSubtitle: String { MainMenuLocalizationKey.menuDisableAdsSubtitle.localized(locale) }

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
        MenuCardAction(
            title: menuCalculatorTitle,
            subtitle: menuCalculatorSubtitle,
            systemImage: "plus.slash.minus",
            style: .primary,
            layout: layout,
            showsSubtitle: layout.showsPrimarySubtitle,
            onTap: {
                onRouteRequested(.section(.calculator))
            }
        )
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
        MenuCardAction(
            title: menuSettingsTitle,
            subtitle: menuSettingsSubtitle,
            systemImage: "slider.horizontal.3",
            style: .standard,
            layout: layout,
            showsSubtitle: layout.showsSecondarySubtitle,
            onTap: {
                onRouteRequested(.section(.settings))
            }
        )
    }

    func instructionsAction(_ layout: MenuLayout) -> some View {
        MenuCardAction(
            title: menuInstructionsTitle,
            subtitle: menuInstructionsSubtitle,
            systemImage: "book.closed",
            style: .standard,
            layout: layout,
            showsSubtitle: layout.showsSecondarySubtitle,
            onTap: {
                onRouteRequested(.section(.instructions))
            }
        )
    }

    func feedbackAction(_ layout: MenuLayout) -> some View {
        MenuCardButton(
            title: menuFeedbackTitle,
            subtitle: menuFeedbackSubtitle,
            systemImage: "envelope",
            style: .standard,
            layout: layout,
            showsSubtitle: layout.showsSecondarySubtitle
        ) {
            openFeedbackMail()
        }
    }

    func disableAdsAction(_ layout: MenuLayout) -> some View {
        MenuCardAction(
            title: menuDisableAdsTitle,
            subtitle: menuDisableAdsSubtitle,
            systemImage: "cart",
            style: .highlight,
            layout: layout,
            showsSubtitle: layout.showsSecondarySubtitle,
            onTap: {
                onRouteRequested(.disableAds)
            }
        )
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

    var feedbackMailSubject: String? {
        Bundle.main.object(forInfoDictionaryKey: FeedbackMailConstants.bundleDisplayNameKey) as? String
            ?? Bundle.main.object(forInfoDictionaryKey: FeedbackMailConstants.bundleNameKey) as? String
    }

    func feedbackMailURL() -> URL? {
        var components = URLComponents()
        components.scheme = FeedbackMailConstants.mailtoScheme
        components.path = FeedbackMailConstants.emailAddress
        if let subject = feedbackMailSubject {
            components.queryItems = [
                URLQueryItem(
                    name: FeedbackMailConstants.subjectQueryName,
                    value: subject
                )
            ]
        }
        return components.url
    }

    func openFeedbackMail() {
        guard let url = feedbackMailURL() else { return }
        openURL(url)
    }

}

#Preview {
    NavigationStack {
        MainMenuView(
            onRouteRequested: { _ in }
        )
    }
}
