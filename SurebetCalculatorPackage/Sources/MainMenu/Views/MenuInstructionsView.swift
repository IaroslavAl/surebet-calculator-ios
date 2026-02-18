import SwiftUI
import DesignSystem

private enum MenuInstructionsAccessibilityIdentifiers {
    static let view = "menu_instructions_view"
}

struct MenuInstructionsView: View {
    // MARK: - Properties

    @Environment(\.locale) private var locale

    // MARK: - Body

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: sectionSpacing) {
                    ForEach(steps) { step in
                        InstructionCard(step: step)
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
            }
        }
        .navigationTitle(instructionsTitle)
        .navigationBarTitleDisplayMode(.large)
        .accessibilityIdentifier(MenuInstructionsAccessibilityIdentifiers.view)
    }
}

// MARK: - Private Computed Properties

private extension MenuInstructionsView {
    var instructionsTitle: String { MainMenuLocalizationKey.menuInstructionsTitle.localized(locale) }
    var sectionSpacing: CGFloat { isIPad ? DesignSystem.Spacing.extraLarge : DesignSystem.Spacing.large }
    var horizontalPadding: CGFloat { DesignSystem.Spacing.large }
    var verticalPadding: CGFloat { isIPad ? DesignSystem.Spacing.extraLarge : DesignSystem.Spacing.large }

    var steps: [InstructionStep] {
        [
            InstructionStep(
                systemImage: "list.number",
                title: MainMenuLocalizationKey.instructionsStepOneTitle.localized(locale),
                message: MainMenuLocalizationKey.instructionsStepOneBody.localized(locale)
            ),
            InstructionStep(
                systemImage: "slider.horizontal.3",
                title: MainMenuLocalizationKey.instructionsStepTwoTitle.localized(locale),
                message: MainMenuLocalizationKey.instructionsStepTwoBody.localized(locale)
            ),
            InstructionStep(
                systemImage: "highlighter",
                title: MainMenuLocalizationKey.instructionsStepThreeTitle.localized(locale),
                message: MainMenuLocalizationKey.instructionsStepThreeBody.localized(locale)
            ),
            InstructionStep(
                systemImage: "trash",
                title: MainMenuLocalizationKey.instructionsStepFourTitle.localized(locale),
                message: MainMenuLocalizationKey.instructionsStepFourBody.localized(locale)
            )
        ]
    }
}

private struct InstructionStep: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: String
    let message: String
}

private struct InstructionCard: View {
    let step: InstructionStep

    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.medium) {
            icon
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                Text(step.title)
                    .font(DesignSystem.Typography.body.weight(.semibold))
                    .foregroundColor(DesignSystem.Color.textPrimary)
                Text(step.message)
                    .font(DesignSystem.Typography.description)
                    .foregroundColor(DesignSystem.Color.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(cardPadding)
        .background(DesignSystem.Color.surface)
        .cornerRadius(cardCornerRadius)
        .overlay {
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .stroke(DesignSystem.Color.borderMuted, lineWidth: 1)
        }
    }

    private var icon: some View {
        Image(systemName: step.systemImage)
            .font(.system(size: iconSize, weight: .semibold))
            .foregroundColor(DesignSystem.Color.accent)
            .frame(width: iconContainerSize, height: iconContainerSize)
            .background(DesignSystem.Color.accentSoft)
            .clipShape(Circle())
    }

    private var cardPadding: CGFloat {
        isIPad ? DesignSystem.Spacing.extraLarge : DesignSystem.Spacing.large
    }

    private var cardCornerRadius: CGFloat {
        isIPad ? DesignSystem.Radius.extraLarge : DesignSystem.Radius.large
    }
    private var iconContainerSize: CGFloat { isIPad ? 52 : 40 }
    private var iconSize: CGFloat { isIPad ? 22 : 16 }
}

#Preview {
    NavigationStack {
        MenuInstructionsView()
    }
}
