import Banner
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
        scrollableContent
            .frame(maxWidth: .infinity)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: toolbar)
            .frame(minHeight: 0, maxHeight: .infinity, alignment: .top)
            .font(AppConstants.Typography.body)
            .environmentObject(viewModel)
            .animation(.default, value: viewModel.selectedNumberOfRows)
            .focused($isFocused)
            .onTapGesture {
                isFocused = false
            }
    }
}

// MARK: - Private Methods

private extension SurebetCalculatorView {
    var scrollableContent: some View {
        VStack(spacing: spacing) {
            ScrollViewReader { proxy in
                scrollView(proxy: proxy)
                    .onChange(of: viewModel.selectedNumberOfRows) { _ in
                        scrollToEnd(proxy: proxy)
                    }
            }
        }
    }

    func scrollView(proxy: ScrollViewProxy) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: spacing) {
                TotalRowView()
                    .padding(.trailing, horizontalPadding)
                rowsView
                actionButtons
                    .id("EndOfView")
            }
            .padding(rowsSpacing)
            .background(backgroundTapGesture)
        }
    }

    var backgroundTapGesture: some View {
        Color.clear
            .contentShape(.rect)
            .onTapGesture {
                viewModel.send(.hideKeyboard)
            }
    }

    var actionButtons: some View {
        HStack(spacing: .zero) {
            removeButton
            addButton
        }
    }

    func scrollToEnd(proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo("EndOfView", anchor: .bottom)
        }
    }

    var rowsView: some View {
        VStack(spacing: rowsSpacing) {
            ForEach(Array(viewModel.activeRowIds.enumerated()), id: \.element) { index, id in
                RowView(rowId: id, displayIndex: index)
            }
        }
        .padding(.trailing, horizontalPadding)
    }

    @ToolbarContentBuilder
    func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            NavigationClearButton()
        }
        // WORKAROUND: ToolbarItemGroup(placement: .keyboard) вызывает runtime warning
        // "Invalid frame dimension (negative or non-finite)" - это известный баг SwiftUI.
        // Warning безвреден и не влияет на работу приложения.
        // https://developer.apple.com/forums/thread/709656
        ToolbarItemGroup(placement: .keyboard) {
            KeyboardClearButton()
            Spacer(minLength: 0)
            KeyboardDoneButton()
        }
    }

    var addButton: some View {
        Image(systemName: "plus.circle")
            .foregroundStyle(
                viewModel.selectedNumberOfRows == .twenty
                    ? AppColors.inactiveButton
                    : AppColors.activeButton
            )
            .font(AppConstants.Typography.button)
            .disabled(viewModel.selectedNumberOfRows == .twenty)
            .padding(AppConstants.Padding.small)
            .contentShape(.rect)
            .onTapGesture {
                viewModel.send(.addRow)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            .accessibilityIdentifier(AccessibilityIdentifiers.Calculator.addRowButton)
    }

    var removeButton: some View {
        Image(systemName: "minus.circle")
            .foregroundStyle(
                viewModel.selectedNumberOfRows == .two
                    ? AppColors.inactiveButton
                    : AppColors.primaryRed
            )
            .font(AppConstants.Typography.button)
            .disabled(viewModel.selectedNumberOfRows == .two)
            .padding(AppConstants.Padding.small)
            .contentShape(.rect)
            .onTapGesture {
                viewModel.send(.removeRow)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            .accessibilityIdentifier(AccessibilityIdentifiers.Calculator.removeRowButton)
    }
}

// MARK: - Private Computed Properties

private extension SurebetCalculatorView {
    var navigationTitle: String { SurebetCalculatorLocalizationKey.navigationTitle.localized }
    var spacing: CGFloat { isIPad ? AppConstants.Padding.extraLarge : AppConstants.Padding.large }
    var rowsSpacing: CGFloat { isIPad ? AppConstants.Padding.medium : AppConstants.Padding.small }
    var horizontalPadding: CGFloat { isIPad ? AppConstants.Padding.small : AppConstants.Padding.small }
}

#Preview {
    SurebetCalculatorView(viewModel: SurebetCalculatorViewModel())
}
