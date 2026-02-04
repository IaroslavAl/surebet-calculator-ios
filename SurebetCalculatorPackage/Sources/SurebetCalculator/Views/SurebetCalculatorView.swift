import Banner
import Foundation
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
        VStack(spacing: spacing) {
            scrollView
        }
    }

    var scrollView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: spacing) {
                rowCountPicker
                TotalRowView()
                    .padding(.trailing, horizontalPadding)
                rowsView
            }
            .padding(.vertical, rowsSpacing)
            // leading отступ уже внутри rowsView у ToggleButton
            .padding(.trailing, rowsSpacing)
            .background(backgroundTapGesture)
        }
        .scrollDismissesKeyboard(.immediately)
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
        .padding(.trailing, horizontalPadding)
    }

    @ToolbarContentBuilder
    func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            NavigationClearButton()
        }
    }

    var rowCountPicker: some View {
        VStack(alignment: .center, spacing: rowsSpacing) {
            Text(rowCountLabel)
                .font(AppConstants.Typography.label)
                .frame(maxWidth: .infinity, alignment: .center)
            GeometryReader { proxy in
                HorizontalWheelPicker(
                    options: viewModel.availableRowCounts.map(\.rawValue),
                    selection: rowCountIntBinding,
                    itemWidth: max(72, proxy.size.width / 4.5),
                    itemHeight: pickerHeight,
                    itemSpacing: max(10, proxy.size.width / 35)
                )
                .accessibilityIdentifier(AccessibilityIdentifiers.Calculator.rowCountPicker)
            }
            .frame(maxWidth: .infinity, minHeight: pickerHeight, maxHeight: pickerHeight)
        }
    }

}

// MARK: - Private Computed Properties

private extension SurebetCalculatorView {
    var navigationTitle: String { SurebetCalculatorLocalizationKey.navigationTitle.localized }
    var rowCountLabel: String { SurebetCalculatorLocalizationKey.outcomesCount.localized }
    var spacing: CGFloat { isIPad ? AppConstants.Padding.extraLarge : AppConstants.Padding.large }
    var rowsSpacing: CGFloat { isIPad ? AppConstants.Padding.medium : AppConstants.Padding.small }
    var horizontalPadding: CGFloat { isIPad ? AppConstants.Padding.small : AppConstants.Padding.small }
    var pickerHeight: CGFloat { isIPad ? AppConstants.Heights.regular : AppConstants.Heights.compact }
    var rowCountBinding: Binding<NumberOfRows> {
        Binding(
            get: { viewModel.selectedNumberOfRows },
            set: { viewModel.send(.setNumberOfRows($0)) }
        )
    }
    var rowCountIntBinding: Binding<Int> {
        Binding(
            get: { viewModel.selectedNumberOfRows.rawValue },
            set: { newValue in
                guard let selected = NumberOfRows(rawValue: newValue) else { return }
                guard selected != viewModel.selectedNumberOfRows else { return }
                DispatchQueue.main.async {
                    viewModel.send(.setNumberOfRows(selected))
                }
            }
        )
    }
}

#Preview {
    SurebetCalculatorView(viewModel: SurebetCalculatorViewModel())
}
