import SwiftUI

struct KeyboardDoneButton: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

    // MARK: - Body

    var body: some View {
        Button(text) {
            viewModel.send(.hideKeyboard)
        }
    }
}

// MARK: - Private Computed Properties

private extension KeyboardDoneButton {
    var text: String { String(localized: "Done") }
}

#Preview {
    KeyboardDoneButton()
        .environmentObject(SurebetCalculatorViewModel())
}
