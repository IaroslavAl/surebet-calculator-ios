import SwiftUI
import DesignSystem

struct CalculatorTextFieldStyle: TextFieldStyle {
    let isEnabled: Bool
    let isValid: Bool
    let isFocused: Bool

    // swiftlint:disable:next identifier_name
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .multilineTextAlignment(.center)
            .padding(padding)
            .frame(minWidth: 0, minHeight: frameHeight, maxHeight: frameHeight)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .keyboardType(.decimalPad)
    }
}

private extension CalculatorTextFieldStyle {
    var padding: CGFloat {
        Device.isIPadUnsafe ? DesignSystem.Spacing.large : DesignSystem.Spacing.small
    }
    var frameHeight: CGFloat {
        Device.isIPadUnsafe ? DesignSystem.Size.controlRegularHeight : DesignSystem.Size.controlCompactHeight
    }
    var cornerRadius: CGFloat {
        Device.isIPadUnsafe ? DesignSystem.Radius.large : DesignSystem.Radius.small
    }
    var backgroundColor: Color {
        if !isEnabled {
            return DesignSystem.Color.surfaceResult
        }
        return isValid ? DesignSystem.Color.surfaceInput : DesignSystem.Color.errorBackground
    }
}

extension TextFieldStyle where Self == CalculatorTextFieldStyle {
    static func calculatorStyle(
        isEnabled: Bool,
        isValid: Bool,
        isFocused: Bool
    ) -> CalculatorTextFieldStyle {
        CalculatorTextFieldStyle(
            isEnabled: isEnabled,
            isValid: isValid,
            isFocused: isFocused
        )
    }
}
