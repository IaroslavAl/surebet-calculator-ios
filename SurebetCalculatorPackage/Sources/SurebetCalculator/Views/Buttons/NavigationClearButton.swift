import SwiftUI

struct NavigationClearButton: View {
    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

    var body: some View {
        Button {
            viewModel.send(.clearAll)
        } label: {
            Image(systemName: "trash")
                .accessibilityLabel(String(localized: "Clear all"))
        }
    }
}

#Preview {
    NavigationClearButton()
        .environmentObject(SurebetCalculatorViewModel())
}
