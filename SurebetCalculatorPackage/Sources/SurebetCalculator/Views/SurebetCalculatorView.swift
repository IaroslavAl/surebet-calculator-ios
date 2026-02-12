import SwiftUI
import DesignSystem

struct SurebetCalculatorView: View {
    // MARK: - Properties

    @ObservedObject private var viewModel: SurebetCalculatorViewModel
    @StateObject private var keyboardActionProxy = KeyboardAccessoryActionProxy()
    @Environment(\.locale) private var locale

    @FocusState private var focusedField: FocusableField?

    // MARK: - Initialization

    init(viewModel: SurebetCalculatorViewModel) {
        self.viewModel = viewModel
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
        .onAppear {
            keyboardActionProxy.update(
                onClear: { viewModel.send(.clearFocusableField) },
                onDone: dismissKeyboard
            )
            focusedField = viewModel.focus
        }
        .onChange(of: focusedField) { newFocus in
            guard viewModel.focus != newFocus else { return }
            viewModel.send(.setFocus(newFocus))
        }
        .onChange(of: viewModel.focus) { focus in
            guard focusedField != focus else { return }
            focusedField = focus
        }
        .background(
            KeyboardAccessoryOverlayHost(actionProxy: keyboardActionProxy)
        )
    }
}

// MARK: - Private Methods

private extension SurebetCalculatorView {
    var scrollableContent: some View {
        scrollView
    }

    var scrollView: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .top) {
                    backgroundTapGesture
                    VStack(spacing: sectionSpacing) {
                        OutcomeCountControlView(
                            viewModel: viewModel.outcomeCountViewModel,
                            onRemove: { viewModel.send(.removeRow) },
                            onAdd: { viewModel.send(.addRow) }
                        )
                        TotalRowView(
                            viewModel: viewModel.totalRowViewModel,
                            focusedField: $focusedField,
                            onSelect: { viewModel.send(.selectRow(.total)) },
                            onBetSizeChange: { text in
                                viewModel.send(.setTextFieldText(.totalBetSize, text))
                            }
                        )
                        rowsHeader
                        rowsView
                    }
                    .padding(.vertical, sectionSpacing)
                    .padding(.horizontal, horizontalPadding)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height, alignment: .top)
            }
            .scrollDismissesKeyboard(.immediately)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: keyboardAccessoryInset)
            }
        }
    }

    var backgroundTapGesture: some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .contentShape(.rect)
            .allowsHitTesting(viewModel.focus != nil)
            .onTapGesture {
                dismissKeyboard()
            }
    }

    var rowsView: some View {
        VStack(spacing: rowsSpacing) {
            ForEach(viewModel.activeRowViewModels) { rowViewModel in
                RowView(
                    viewModel: rowViewModel,
                    focusedField: $focusedField,
                    onSelect: { viewModel.send(.selectRow(.row(rowViewModel.id))) },
                    onCoefficientChange: { text in
                        viewModel.send(.setTextFieldText(.rowCoefficient(rowViewModel.id), text))
                    },
                    onBetSizeChange: { text in
                        viewModel.send(.setTextFieldText(.rowBetSize(rowViewModel.id), text))
                    }
                )
            }
        }
        .animation(DesignSystem.Animation.quickInteraction, value: viewModel.activeRowViewModelIDs)
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
            NavigationClearButton(onClear: { viewModel.send(.clearAll) })
        }
    }

    func dismissKeyboard() {
        guard viewModel.focus != nil || focusedField != nil else { return }
        focusedField = nil
        viewModel.send(.hideKeyboard)
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
    SurebetCalculatorView(
        viewModel: SurebetCalculatorViewModel(
            calculationService: DefaultCalculationService(),
            analytics: NoopCalculatorAnalytics(),
            delay: SystemCalculationAnalyticsDelay()
        )
    )
}

#Preview("RU") {
    SurebetCalculatorView(
        viewModel: SurebetCalculatorViewModel(
            calculationService: DefaultCalculationService(),
            analytics: NoopCalculatorAnalytics(),
            delay: SystemCalculationAnalyticsDelay()
        )
    )
        .environment(\.locale, Locale(identifier: "ru"))
}
