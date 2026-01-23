import Banner
import SwiftUI

struct SurebetCalculatorView: View {
    // MARK: - Properties

    @StateObject
    private var viewModel = SurebetCalculatorViewModel()

    @FocusState
    private var isFocused

    // MARK: - Body

    var body: some View {
        scrollableContent
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: toolbar)
            .frame(maxHeight: .infinity, alignment: .top)
            .font(font)
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
            ForEach(viewModel.displayedRowIndexes, id: \.self) { id in
                RowView(id: id)
            }
        }
        .padding(.trailing, horizontalPadding)
    }

    @ToolbarContentBuilder
    func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            NavigationClearButton()
        }
        ToolbarItemGroup(placement: .keyboard) {
            KeyboardClearButton()
            Spacer()
            KeyboardDoneButton()
        }
    }

    var addButton: some View {
        Image(systemName: "plus.circle")
            .foregroundStyle(viewModel.selectedNumberOfRows == .ten ? .gray : .green)
            .font(buttonFont)
            .disabled(viewModel.selectedNumberOfRows == .ten)
            .padding(AppConstants.Padding.small)
            .contentShape(.rect)
            .onTapGesture {
                viewModel.send(.addRow)
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
    }

    var removeButton: some View {
        Image(systemName: "minus.circle")
            .foregroundStyle(viewModel.selectedNumberOfRows == .two ? .gray : .red)
            .font(buttonFont)
            .disabled(viewModel.selectedNumberOfRows == .two)
            .padding(AppConstants.Padding.small)
            .contentShape(.rect)
            .onTapGesture {
                viewModel.send(.removeRow)
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
    }
}

// MARK: - Private Computed Properties

private extension SurebetCalculatorView {
    var navigationTitle: String { String(localized: "Surebet calculator") }
    var spacing: CGFloat { isIPad ? AppConstants.Padding.extraLarge : AppConstants.Padding.large }
    var rowsSpacing: CGFloat { isIPad ? AppConstants.Padding.medium : AppConstants.Padding.small }
    var horizontalPadding: CGFloat { isIPad ? AppConstants.Padding.medium : AppConstants.Padding.small }
    var font: Font { isIPad ? .title : .body }
    var buttonFont: Font { isIPad ? .largeTitle : .title }
}

#Preview {
    SurebetCalculatorView()
}
