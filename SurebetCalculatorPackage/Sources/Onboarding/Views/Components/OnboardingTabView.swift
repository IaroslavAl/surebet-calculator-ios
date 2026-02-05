import SwiftUI
import DesignSystem

struct OnboardingTabView: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: OnboardingViewModel

    // MARK: - Body

    var body: some View {
        TabView(selection: selection) {
            ForEach(viewModel.pages.indices, id: \.self) { index in
                OnboardingPageView(page: viewModel.pages[index])
                    .tag(index)
                    .accessibilityIdentifier(OnboardingAccessibilityIdentifiers.pageView(index))
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(DesignSystem.Animation.smoothTransition, value: viewModel.currentPage)
        .transition(DesignSystem.Animation.moveFromTrailing)
        .accessibilityIdentifier(OnboardingAccessibilityIdentifiers.tabView)
    }
}

// MARK: - Private Computed Properties

private extension OnboardingTabView {
    var selection: Binding<Int> {
        .init(
            get: { viewModel.currentPage },
            set: { viewModel.send(.setCurrentPage($0)) }
        )
    }
}

#Preview {
    OnboardingTabView()
        .environmentObject(OnboardingViewModel())
}
