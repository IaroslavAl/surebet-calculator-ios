import SwiftUI
import DesignSystem

struct SurebetCalculatorView: View {
    // MARK: - Properties

    @StateObject
    private var viewModel: SurebetCalculatorViewModel
    @Environment(\.locale) private var locale

    @FocusState
    private var isFocused

    // MARK: - Initialization

    init(viewModel: SurebetCalculatorViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            scrollableContent
        }
        .frame(maxWidth: .infinity)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: toolbar)
        .frame(minHeight: .zero, maxHeight: .infinity, alignment: .top)
        .font(DesignSystem.Typography.body)
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
            .font(DesignSystem.Typography.label)
            .foregroundColor(DesignSystem.Color.textSecondary)
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
    var navigationTitle: String { SurebetCalculatorLocalizationKey.navigationTitle.localized(locale) }
    var coefficientText: String { SurebetCalculatorLocalizationKey.coefficient.localized(locale) }
    var betSizeText: String { SurebetCalculatorLocalizationKey.betSize.localized(locale) }
    var payoutText: String { SurebetCalculatorLocalizationKey.income.localized(locale) }
    var sectionSpacing: CGFloat { isIPad ? DesignSystem.Spacing.large : DesignSystem.Spacing.medium }
    var rowsSpacing: CGFloat { isIPad ? DesignSystem.Spacing.medium : DesignSystem.Spacing.small }
    var columnSpacing: CGFloat { isIPad ? DesignSystem.Spacing.large : DesignSystem.Spacing.small }
    var horizontalPadding: CGFloat { DesignSystem.Spacing.large }
    var selectionIndicatorSize: CGFloat { isIPad ? 48 : 44 }
    var keyboardAccessoryInset: CGFloat {
        guard viewModel.focus != nil else { return 0 }
        return DesignSystem.Size.keyboardAccessoryToolbarHeight + DesignSystem.Spacing.small
    }
}

#Preview {
    SurebetCalculatorView(viewModel: SurebetCalculatorViewModel())
}

#Preview("RU") {
    SurebetCalculatorView(viewModel: SurebetCalculatorViewModel())
        .environment(\.locale, Locale(identifier: "ru"))
}
