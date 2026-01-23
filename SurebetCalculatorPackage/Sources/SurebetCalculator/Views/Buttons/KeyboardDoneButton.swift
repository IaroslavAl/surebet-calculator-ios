import SwiftUI

struct KeyboardDoneButton: View {
    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

    var body: some View {
        Button(text) {
            viewModel.send(.hideKeyboard)
        }
    }
}

private extension KeyboardDoneButton {
    var text: String { String(localized: "Done") }
}

#Preview {
    KeyboardDoneButton()
        .environmentObject(SurebetCalculatorViewModel())
}
