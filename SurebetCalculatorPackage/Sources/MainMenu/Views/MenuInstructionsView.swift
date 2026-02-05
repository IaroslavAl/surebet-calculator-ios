import SurebetCalculator
import SwiftUI

struct MenuInstructionsView: View {
    // MARK: - Body

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: sectionSpacing) {
                    header
                    ForEach(steps) { step in
                        InstructionCard(step: step)
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
            }
        }
        .navigationTitle(instructionsTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Private Computed Properties

private extension MenuInstructionsView {
    var instructionsTitle: String { MainMenuLocalizationKey.menuInstructionsTitle.localized }
    var instructionsSubtitle: String { MainMenuLocalizationKey.instructionsSubtitle.localized }
    var sectionSpacing: CGFloat { isIPad ? AppConstants.Padding.extraLarge : AppConstants.Padding.large }
    var horizontalPadding: CGFloat { AppConstants.Padding.large }
    var verticalPadding: CGFloat { isIPad ? AppConstants.Padding.extraLarge : AppConstants.Padding.large }

    var header: some View {
        VStack(alignment: .leading, spacing: AppConstants.Padding.small) {
            Text(instructionsTitle)
                .font(AppConstants.Typography.title)
                .foregroundColor(AppColors.textPrimary)
            Text(instructionsSubtitle)
                .font(AppConstants.Typography.description)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var steps: [InstructionStep] {
        [
            InstructionStep(
                systemImage: "list.number",
                title: MainMenuLocalizationKey.instructionsStepOneTitle.localized,
                message: MainMenuLocalizationKey.instructionsStepOneBody.localized
            ),
            InstructionStep(
                systemImage: "percent",
                title: MainMenuLocalizationKey.instructionsStepTwoTitle.localized,
                message: MainMenuLocalizationKey.instructionsStepTwoBody.localized
            ),
            InstructionStep(
                systemImage: "target",
                title: MainMenuLocalizationKey.instructionsStepThreeTitle.localized,
                message: MainMenuLocalizationKey.instructionsStepThreeBody.localized
            ),
            InstructionStep(
                systemImage: "checkmark.seal",
                title: MainMenuLocalizationKey.instructionsStepFourTitle.localized,
                message: MainMenuLocalizationKey.instructionsStepFourBody.localized
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
        HStack(alignment: .top, spacing: AppConstants.Padding.medium) {
            icon
            VStack(alignment: .leading, spacing: AppConstants.Padding.small) {
                Text(step.title)
                    .font(AppConstants.Typography.body.weight(.semibold))
                    .foregroundColor(AppColors.textPrimary)
                Text(step.message)
                    .font(AppConstants.Typography.description)
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(cardPadding)
        .background(AppColors.surface)
        .cornerRadius(cardCornerRadius)
        .overlay {
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .stroke(AppColors.borderMuted, lineWidth: 1)
        }
    }

    private var icon: some View {
        Image(systemName: step.systemImage)
            .font(.system(size: iconSize, weight: .semibold))
            .foregroundColor(AppColors.accent)
            .frame(width: iconContainerSize, height: iconContainerSize)
            .background(AppColors.accentSoft)
            .clipShape(Circle())
    }

    private var cardPadding: CGFloat {
        isIPad ? AppConstants.Padding.extraLarge : AppConstants.Padding.large
    }

    private var cardCornerRadius: CGFloat {
        isIPad ? AppConstants.CornerRadius.extraLarge : AppConstants.CornerRadius.large
    }
    private var iconContainerSize: CGFloat { isIPad ? 52 : 40 }
    private var iconSize: CGFloat { isIPad ? 22 : 16 }
}

#Preview {
    NavigationStack {
        MenuInstructionsView()
    }
}
