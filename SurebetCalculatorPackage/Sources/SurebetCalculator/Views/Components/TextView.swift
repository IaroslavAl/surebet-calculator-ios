import SwiftUI

struct TextView: View {
    let text: String
    let isPercent: Bool

    var body: some View {
        Text(text)
            .padding(textPadding)
            .frame(height: frameHeight)
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemFill))
            .cornerRadius(cornerRadius)
            .foregroundColor(color)
    }
}

private extension TextView {
    var textPadding: CGFloat { AppConstants.Layout.Padding.small }
    var iPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    var frameHeight: CGFloat { iPad ? AppConstants.Layout.Heights.regular : AppConstants.Layout.Heights.compact }
    var cornerRadius: CGFloat { iPad ? AppConstants.Layout.CornerRadius.large : AppConstants.Layout.CornerRadius.small }
    var color: Color { text.isNumberNotNegative() ? .green : .red }
}

#Preview {
    TextView(text: 1.formatToString(isPercent: true), isPercent: true)
        .padding()
}
