import SwiftUI

struct CalculatorTextFieldStyle: TextFieldStyle {
    let isEnabled: Bool
    let isValid: Bool

    // swiftlint:disable:next identifier_name
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .multilineTextAlignment(.center)
            .padding(padding)
            .frame(minWidth: 0, minHeight: frameHeight, maxHeight: frameHeight)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .keyboardType(.decimalPad)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(strokeColor, lineWidth: strokeLineWidth)
            }
            .animation(AppConstants.Animations.quickInteraction, value: isValid)
            .animation(AppConstants.Animations.quickInteraction, value: isEnabled)
    }
}

private extension CalculatorTextFieldStyle {
    var padding: CGFloat { AppConstants.Padding.small }
    var frameHeight: CGFloat {
        Device.isIPadUnsafe ? AppConstants.Heights.regular : AppConstants.Heights.compact
    }
    var cornerRadius: CGFloat {
        Device.isIPadUnsafe ? AppConstants.CornerRadius.large : AppConstants.CornerRadius.small
    }
    var strokeLineWidth: CGFloat { Device.isIPadUnsafe ? 1.5 : 1 }
    var strokeColor: Color { isEnabled ? AppColors.primaryGreen : .clear }
    var backgroundColor: Color {
        isValid ? AppColors.textFieldBackground : AppColors.errorBackground
    }
}

extension TextFieldStyle where Self == CalculatorTextFieldStyle {
    static func calculatorStyle(
        isEnabled: Bool,
        isValid: Bool
    ) -> CalculatorTextFieldStyle {
        CalculatorTextFieldStyle(isEnabled: isEnabled, isValid: isValid)
    }
}
