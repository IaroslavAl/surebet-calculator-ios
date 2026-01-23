import SwiftUI

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
            }
        }
        .animation(.default, value: viewModel.currentPage)
        .padding(padding)
        .fixedSize()
    }
}

// MARK: - Private Methods

private extension OnboardingIndex {
    var iPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    var spacing: CGFloat { iPad ? OnboardingConstants.paddingMedium : OnboardingConstants.paddingSmall }
    var padding: CGFloat { iPad ? OnboardingConstants.paddingExtraExtraLarge : OnboardingConstants.paddingExtraLarge }

    func size(_ index: Int) -> CGFloat {
        if index == viewModel.currentPage {
            iPad ? OnboardingConstants.cornerRadiusExtraLarge : OnboardingConstants.cornerRadiusMedium
        } else {
            iPad ? OnboardingConstants.cornerRadiusMedium : OnboardingConstants.paddingSmall
        }
    }

    func color(_ index: Int) -> Color {
        Color(uiColor: index == viewModel.currentPage ? .darkGray : .lightGray)
    }
}

#Preview {
    OnboardingIndex()
        .environmentObject(OnboardingViewModel())
}
