import SwiftUI

struct OnboardingButton: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: OnboardingViewModel

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            label
        }
        .accessibilityLabel(text)
        .accessibilityIdentifier(OnboardingAccessibilityIdentifiers.nextButton)
    }
}

// MARK: - Private Methods

private extension OnboardingButton {
    var text: String {
        let firstPage = OnboardingConstants.firstPageIndex
        let lastPage = viewModel.pages.index(before: viewModel.pages.endIndex)
        if viewModel.currentPage == firstPage {
            return String(localized: "More details", bundle: .module)
        }
        if viewModel.currentPage == lastPage {
            return String(localized: "Close", bundle: .module)
        }
        return String(localized: "Next", bundle: .module)
    }
    var cornerRadius: CGFloat {
        isIPad ? OnboardingConstants.cornerRadiusExtraLarge : OnboardingConstants.cornerRadiusMedium
    }

    func action() {
        viewModel.send(.setCurrentPage(viewModel.currentPage + 1))
    }

    var label: some View {
        Text(text)
            .foregroundColor(.white)
            .bold()
            .frame(maxWidth: .infinity)
            .padding()
            .background(.green)
            .cornerRadius(cornerRadius)
            .animation(.none, value: viewModel.currentPage)
    }
}

#Preview {
    OnboardingButton()
        .environmentObject(OnboardingViewModel())
}
