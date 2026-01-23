import SwiftUI

struct OnboardingIndex: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

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

private extension OnboardingIndex {
    var iPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    var spacing: CGFloat { iPad ? AppConstants.Layout.Padding.medium : AppConstants.Layout.Padding.small }
    var padding: CGFloat { iPad ? AppConstants.Layout.Padding.extraExtraLarge : AppConstants.Layout.Padding.extraLarge }

    func size(_ index: Int) -> CGFloat {
        if index == viewModel.currentPage {
            iPad ? AppConstants.Layout.CornerRadius.extraLarge : AppConstants.Layout.CornerRadius.medium
        } else {
            iPad ? AppConstants.Layout.CornerRadius.medium : AppConstants.Layout.Padding.small
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
