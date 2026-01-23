import SwiftUI

struct KeyboardClearButton: View {
    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

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
