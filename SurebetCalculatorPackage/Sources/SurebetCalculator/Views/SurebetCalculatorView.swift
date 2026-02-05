import SwiftUI

struct SurebetCalculatorView: View {
    // MARK: - Properties

    @StateObject
    private var viewModel: SurebetCalculatorViewModel

    @FocusState
    private var isFocused

    // MARK: - Initialization

    init(viewModel: SurebetCalculatorViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            scrollableContent
        }
        .frame(maxWidth: .infinity)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: toolbar)
        .frame(minHeight: .zero, maxHeight: .infinity, alignment: .top)
        .font(AppConstants.Typography.body)
        .environmentObject(viewModel)
        .animation(.default, value: viewModel.selectedNumberOfRows)
        .focused($isFocused)
        .onTapGesture {
            isFocused = false
        }
        .background(
            KeyboardAccessoryOverlayHost(
                onClear: { viewModel.send(.clearFocusableField) },
                onDone: { viewModel.send(.hideKeyboard) }
            )
        )
    }
}

// MARK: - Private Methods

private extension SurebetCalculatorView {
    var scrollableContent: some View {
        scrollView
    }

    var scrollView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: sectionSpacing) {
                OutcomeCountControlView()
                TotalRowView()
                rowsHeader
                rowsView
            }
            .padding(.vertical, sectionSpacing)
            .padding(.horizontal, horizontalPadding)
            .background(backgroundTapGesture)
        }
        .scrollDismissesKeyboard(.immediately)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear.frame(height: keyboardAccessoryInset)
        }
    }

    var backgroundTapGesture: some View {
        Color.clear
            .contentShape(.rect)
            .onTapGesture {
                viewModel.send(.hideKeyboard)
            }
    }

    var rowsView: some View {
        VStack(spacing: rowsSpacing) {
            ForEach(Array(viewModel.activeRowIds.enumerated()), id: \.element) { index, id in
                RowView(rowId: id, displayIndex: index)
            }
        }
    }

    var rowsHeader: some View {
        HStack(spacing: columnSpacing) {
            Color.clear
                .frame(width: selectionIndicatorSize, height: 1)
            headerText(coefficientText)
            headerText(betSizeText)
            headerText(payoutText)
        }
    }

    func headerText(_ text: String) -> some View {
        Text(text)
            .font(AppConstants.Typography.label)
            .foregroundColor(AppColors.textSecondary)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    @ToolbarContentBuilder
    func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            NavigationClearButton()
        }
    }

}

// MARK: - Private Computed Properties

private extension SurebetCalculatorView {
    var navigationTitle: String { SurebetCalculatorLocalizationKey.navigationTitle.localized }
    var coefficientText: String { SurebetCalculatorLocalizationKey.coefficient.localized }
    var betSizeText: String { SurebetCalculatorLocalizationKey.betSize.localized }
    var payoutText: String { SurebetCalculatorLocalizationKey.income.localized }
    var sectionSpacing: CGFloat { isIPad ? AppConstants.Padding.large : AppConstants.Padding.medium }
    var rowsSpacing: CGFloat { isIPad ? AppConstants.Padding.medium : AppConstants.Padding.small }
    var columnSpacing: CGFloat { isIPad ? AppConstants.Padding.large : AppConstants.Padding.small }
    var horizontalPadding: CGFloat { AppConstants.Padding.large }
    var selectionIndicatorSize: CGFloat { isIPad ? 48 : 44 }
    var keyboardAccessoryInset: CGFloat {
        guard viewModel.focus != nil else { return 0 }
        return AppConstants.Heights.keyboardAccessoryToolbar + AppConstants.Padding.small
    }
}

#Preview {
    SurebetCalculatorView(viewModel: SurebetCalculatorViewModel())
}

#Preview("RU") {
    SurebetCalculatorView(viewModel: SurebetCalculatorViewModel())
        .environment(\.locale, Locale(identifier: "ru"))
}
