import SwiftUI

struct OnboardingButton: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: OnboardingViewModel

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            label
        }
    }
}

// MARK: - Private Methods

private extension OnboardingButton {
    var text: String {
        let firstPage = OnboardingConstants.firstPageIndex
        let lastPage = viewModel.pages.index(before: viewModel.pages.endIndex)
        if viewModel.currentPage == firstPage {
            return String(localized: "More details")
        }
        if viewModel.currentPage == lastPage {
            return String(localized: "Close")
        }
        return String(localized: "Next")
    }
    var iPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    var cornerRadius: CGFloat {
        iPad ? OnboardingConstants.cornerRadiusExtraLarge : OnboardingConstants.cornerRadiusMedium
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
