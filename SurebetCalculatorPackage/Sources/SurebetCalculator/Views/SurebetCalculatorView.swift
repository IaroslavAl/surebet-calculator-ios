import Banner
import SwiftUI

struct SurebetCalculatorView: View {
    @StateObject
    private var viewModel = SurebetCalculatorViewModel()

    @FocusState
    private var isFocused

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
            .padding(AppConstants.Layout.Padding.small)
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
            .padding(AppConstants.Layout.Padding.small)
            .contentShape(.rect)
            .onTapGesture {
                viewModel.send(.removeRow)
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
    }
}

private extension SurebetCalculatorView {
    var navigationTitle: String { String(localized: "Surebet calculator") }
    var iPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    var spacing: CGFloat { iPad ? AppConstants.Layout.Padding.extraLarge : AppConstants.Layout.Padding.large }
    var rowsSpacing: CGFloat { iPad ? AppConstants.Layout.Padding.medium : AppConstants.Layout.Padding.small }
    var horizontalPadding: CGFloat { iPad ? AppConstants.Layout.Padding.medium : AppConstants.Layout.Padding.small }
    var font: Font { iPad ? .title : .body }
    var buttonFont: Font { iPad ? .largeTitle : .title }
}

#Preview {
    SurebetCalculatorView()
}
