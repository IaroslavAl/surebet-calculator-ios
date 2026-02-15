import SwiftUI
import DesignSystem

private enum SettingsAccessibilityIdentifiers {
    static let view = "settings_view"
    static let headerTitle = "settings_header_title"
    static let themeSection = "settings_theme_section"
    static let languageSection = "settings_language_section"
}

@MainActor
struct SettingsView: View {
    // MARK: - Properties

    @ObservedObject private var viewModel: SettingsViewModel
    @Environment(\.locale) private var locale
    @EnvironmentObject private var languageStore: AppLanguageStore

    // MARK: - Initialization

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: sectionSpacing) {
                    header
                    themeSection
                    languageSection
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier(SettingsAccessibilityIdentifiers.view)
    }
}

// MARK: - Private Computed Properties

private extension SettingsView {
    var navigationTitle: String { SettingsLocalizationKey.navigationTitle.localized(locale) }
    var headerTitle: String { SettingsLocalizationKey.headerTitle.localized(locale) }
    var headerSubtitle: String { SettingsLocalizationKey.headerSubtitle.localized(locale) }
    var themeTitle: String { SettingsLocalizationKey.themeTitle.localized(locale) }
    var themeSubtitle: String { SettingsLocalizationKey.themeSubtitle.localized(locale) }
    var languageTitle: String { SettingsLocalizationKey.languageTitle.localized(locale) }
    var languageSubtitle: String { SettingsLocalizationKey.languageSubtitle.localized(locale) }
    var languageFooter: String { SettingsLocalizationKey.languageFooter.localized(locale) }
    var optionUnavailable: String { SettingsLocalizationKey.optionUnavailable.localized(locale) }

    var sectionSpacing: CGFloat { isIPad ? DesignSystem.Spacing.extraLarge : DesignSystem.Spacing.large }
    var horizontalPadding: CGFloat { DesignSystem.Spacing.large }
    var verticalPadding: CGFloat { isIPad ? DesignSystem.Spacing.extraLarge : DesignSystem.Spacing.large }
    var optionSpacing: CGFloat { DesignSystem.Spacing.small }

    var header: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text(headerTitle)
                .font(DesignSystem.Typography.title)
                .foregroundColor(DesignSystem.Color.textPrimary)
                .accessibilityIdentifier(SettingsAccessibilityIdentifiers.headerTitle)
            Text(headerSubtitle)
                .font(DesignSystem.Typography.description)
                .foregroundColor(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var themeSection: some View {
        SettingsSectionCard(
            title: themeTitle,
            subtitle: themeSubtitle,
            systemImage: "paintbrush"
        ) {
            VStack(spacing: optionSpacing) {
                ForEach(SettingsTheme.allCases, id: \.self) { theme in
                    SettingsOptionRow(
                        title: theme.title(locale: locale),
                        subtitle: theme.subtitle(locale: locale),
                        isSelected: viewModel.selectedTheme == theme,
                        isEnabled: true,
                        leading: {
                            Image(systemName: theme.systemImageName)
                                .font(DesignSystem.Typography.icon)
                                .foregroundColor(DesignSystem.Color.accent)
                                .frame(width: isIPad ? 32 : 28, height: isIPad ? 32 : 28)
                                .background(DesignSystem.Color.surface)
                                .clipShape(Circle())
                        },
                        action: {
                            viewModel.send(.selectTheme(theme))
                        }
                    )
                }
            }
        }
        .accessibilityIdentifier(SettingsAccessibilityIdentifiers.themeSection)
    }

    var languageSection: some View {
        SettingsSectionCard(
            title: languageTitle,
            subtitle: languageSubtitle,
            systemImage: "globe"
        ) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                VStack(spacing: optionSpacing) {
                    ForEach(SettingsLanguage.allCases, id: \.self) { language in
                        SettingsOptionRow(
                            title: language.title(locale: locale),
                            badgeText: optionUnavailable,
                            isSelected: languageStore.selectedLanguage == language,
                            isEnabled: language.isSelectable,
                            leading: {
                                Group {
                                    if let code = language.code(locale: locale) {
                                        Text(code)
                                            .font(DesignSystem.Typography.label.weight(.semibold))
                                    } else {
                                        Image(systemName: "gearshape")
                                            .font(DesignSystem.Typography.icon)
                                    }
                                }
                                .foregroundColor(DesignSystem.Color.textSecondary)
                                .frame(width: isIPad ? 32 : 28, height: isIPad ? 32 : 28)
                                .background(DesignSystem.Color.surface)
                                .clipShape(Circle())
                            },
                            action: {
                                languageStore.setLanguage(language)
                            }
                        )
                    }
                }
                Text(languageFooter)
                    .font(DesignSystem.Typography.label)
                    .foregroundColor(DesignSystem.Color.textMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .accessibilityIdentifier(SettingsAccessibilityIdentifiers.languageSection)
    }
}

#Preview {
    NavigationStack {
        SettingsView(viewModel: SettingsViewModel(themeStore: UserDefaultsThemeStore()))
    }
    .environmentObject(AppLanguageStore())
}

#Preview("RU") {
    NavigationStack {
        SettingsView(viewModel: SettingsViewModel(themeStore: UserDefaultsThemeStore()))
            .environment(\.locale, Locale(identifier: "ru"))
    }
    .environmentObject(AppLanguageStore())
}
