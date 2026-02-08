import SwiftUI
import DesignSystem

struct TextFieldView: View {
    // MARK: - Properties

    let placeholder: String
    let label: String
    let focusableField: FocusableField
    let displayIndex: Int?
    let focusedField: FocusState<FocusableField?>.Binding
    let text: String
    let isDisabled: Bool
    let onTextChange: (String) -> Void

    init(
        placeholder: String,
        label: String? = nil,
        focusableField: FocusableField,
        displayIndex: Int? = nil,
        focusedField: FocusState<FocusableField?>.Binding,
        text: String,
        isDisabled: Bool,
        onTextChange: @escaping (String) -> Void
    ) {
        self.placeholder = placeholder
        self.label = label ?? placeholder
        self.focusableField = focusableField
        self.displayIndex = displayIndex
        self.focusedField = focusedField
        self.text = text
        self.isDisabled = isDisabled
        self.onTextChange = onTextChange
    }

    // MARK: - Body

    var body: some View {
        TextField(placeholder, text: bindingText)
            .textFieldStyle(
                .calculatorStyle(
                    isEnabled: !isDisabled,
                    isValid: isValid,
                    isFocused: isFieldFocused
                )
            )
            .font(DesignSystem.Typography.numeric)
            .foregroundColor(isDisabled ? DesignSystem.Color.textMuted : DesignSystem.Color.textPrimary)
            .tint(DesignSystem.Color.accent)
            .opacity(isDisabled ? 0.7 : 1)
            .contentShape(.rect)
            .focused(focusedField, equals: focusableField)
            .onTapGesture {
                guard !isDisabled else { return }
                focusedField.wrappedValue = focusableField
            }
            .disabled(isDisabled)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderLineWidth)
            }
            .accessibilityIdentifier(accessibilityIdentifier)
            .accessibilityLabel(label)
    }
}

// MARK: - Private Computed Properties

private extension TextFieldView {
    var cornerRadius: CGFloat {
        isIPad ? DesignSystem.Radius.large : DesignSystem.Radius.small
    }

    var borderLineWidth: CGFloat {
        let base: CGFloat = Device.isIPadUnsafe ? 1.4 : 1.1
        if isDisabled {
            return 1
        }
        return isFieldFocused ? base + 0.4 : base
    }

    var borderColor: Color {
        if isDisabled {
            return DesignSystem.Color.borderMuted
        }
        if !isValid {
            return DesignSystem.Color.error
        }
        return isFieldFocused ? DesignSystem.Color.accent : DesignSystem.Color.border
    }

    var bindingText: Binding<String> {
        Binding(
            get: { text },
            set: { updatedText in
                guard updatedText != text else { return }
                onTextChange(updatedText)
            }
        )
    }

    var isFieldFocused: Bool {
        focusedField.wrappedValue == focusableField
    }

    var isValid: Bool {
        switch focusableField {
        case .rowCoefficient:
            return isValidCoefficient(text)
        default:
            return text.isValidDouble()
        }
    }

    var accessibilityIdentifier: String {
        switch focusableField {
        case .totalBetSize:
            return AccessibilityIdentifiers.TotalRow.betSizeTextField
        case .rowBetSize:
            return AccessibilityIdentifiers.Row.betSizeTextField(displayIndex ?? 0)
        case .rowCoefficient:
            return AccessibilityIdentifiers.Row.coefficientTextField(displayIndex ?? 0)
        }
    }

    func isValidCoefficient(_ value: String) -> Bool {
        if value.isEmpty {
            return true
        }
        guard let parsed = value.formatToDouble() else { return false }
        return parsed >= 1
    }
}

private struct TextFieldViewPreview: View {
    @State private var text = "100"
    @FocusState private var focusedField: FocusableField?

    var body: some View {
        TextFieldView(
            placeholder: "",
            label: SurebetCalculatorLocalizationKey.totalBetSize.localized(Locale.current),
            focusableField: .totalBetSize,
            focusedField: $focusedField,
            text: text,
            isDisabled: false,
            onTextChange: { text = $0 }
        )
        .padding()
    }
}

#Preview {
    TextFieldViewPreview()
}
