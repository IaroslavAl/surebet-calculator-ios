import SwiftUI

struct OnboardingButton: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    var body: some View {
        Button(action: action) {
            label
        }
    }
}

private extension OnboardingButton {
    var text: String {
        let firstPage = AppConstants.Other.firstPageIndex
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
    var cornerRadius: CGFloat { iPad ? AppConstants.Layout.CornerRadius.extraLarge : AppConstants.Layout.CornerRadius.medium }

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
