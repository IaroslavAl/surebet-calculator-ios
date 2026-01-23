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
    var textPadding: CGFloat { 8 }
    var iPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    var frameHeight: CGFloat { iPad ? 60 : 40 }
    var cornerRadius: CGFloat { iPad ? 15 : 10 }
    var color: Color { text.isNumberNotNegative() ? .green : .red }
}

#Preview {
    TextView(text: 1.formatToString(isPercent: true), isPercent: true)
        .padding()
}
