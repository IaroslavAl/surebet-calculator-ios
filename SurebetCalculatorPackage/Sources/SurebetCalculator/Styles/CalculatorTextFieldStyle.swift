import SwiftUI

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
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: strokeLineWidth)
            }
            .animation(AppConstants.Animations.quickInteraction, value: isValid)
            .animation(AppConstants.Animations.quickInteraction, value: isEnabled)
            .animation(AppConstants.Animations.quickInteraction, value: isFocused)
    }
}

private extension CalculatorTextFieldStyle {
    var padding: CGFloat {
        Device.isIPadUnsafe ? AppConstants.Padding.large : AppConstants.Padding.small
    }
    var frameHeight: CGFloat {
        Device.isIPadUnsafe ? AppConstants.Heights.regular : AppConstants.Heights.compact
    }
    var cornerRadius: CGFloat {
        Device.isIPadUnsafe ? AppConstants.CornerRadius.large : AppConstants.CornerRadius.small
    }
    var strokeLineWidth: CGFloat {
        let base: CGFloat = Device.isIPadUnsafe ? 1.4 : 1.1
        if !isEnabled {
            return 1
        }
        return isFocused ? base + 0.4 : base
    }
    var borderColor: Color {
        if !isEnabled {
            return AppColors.borderMuted
        }
        if !isValid {
            return AppColors.error
        }
        return isFocused ? AppColors.accent : AppColors.border
    }
    var backgroundColor: Color {
        if !isEnabled {
            return AppColors.surfaceResult
        }
        return isValid ? AppColors.surfaceInput : AppColors.errorBackground
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
