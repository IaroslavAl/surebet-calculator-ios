import SwiftUI

struct KeyboardClearButton: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

    // MARK: - Body

    var body: some View {
        Button {
            viewModel.send(.clearFocusableField)
        } label: {
            Text(String(localized: "Clear"))
                .foregroundColor(.red)
        }
    }
}

#Preview {
    KeyboardClearButton()
        .environmentObject(SurebetCalculatorViewModel())
}
