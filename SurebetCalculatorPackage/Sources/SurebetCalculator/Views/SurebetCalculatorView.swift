import Banner
import SwiftUI

struct SurebetCalculatorView: View {
    @StateObject
    private var viewModel = SurebetCalculatorViewModel()

    @FocusState
    private var isFocused

    var body: some View {
        VStack(spacing: spacing) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: spacing) {
                        TotalRowView()
                            .padding(.trailing, horizontalPadding)
                        rowsView
                        HStack(spacing: .zero) {
                            removeButton
                            addButton
                        }
                        .id("EndOfView")
                    }
                    .padding(rowsSpacing)
                    .background(
                        Color.clear
                            .contentShape(.rect)
                            .onTapGesture {
                                viewModel.send(.hideKeyboard)
                            }
                    )
                }
                .onChange(of: viewModel.selectedNumberOfRows) { _ in
                    withAnimation {
                        proxy.scrollTo("EndOfView", anchor: .bottom)
                    }
                }
            }
//            if !isFocused {
//                Banner.view
//                    .padding(.horizontal, horizontalPadding)
//            }
        }
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
            .padding(8)
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
            .padding(8)
            .contentShape(.rect)
            .onTapGesture {
                viewModel.send(.removeRow)
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
    }
}

private extension SurebetCalculatorView {
    var navigationTitle: String { "Surebet calculator" }
    var iPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    var spacing: CGFloat { iPad ? 24 : 16 }
    var rowsSpacing: CGFloat { iPad ? 12 : 8 }
    var horizontalPadding: CGFloat { iPad ? 12 : 8 }
    var font: Font { iPad ? .title : .body }
    var buttonFont: Font { iPad ? .largeTitle : .title }
}

#Preview {
    SurebetCalculatorView()
}
