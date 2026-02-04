import SwiftUI

struct TextFieldView: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel
    @FocusState private var isFocused: FocusableField?

    let placeholder: String
    let focusableField: FocusableField

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
            .font(AppConstants.Typography.numeric)
            .foregroundColor(isDisabled ? AppColors.textMuted : AppColors.textPrimary)
            .tint(AppColors.accent)
            .opacity(isDisabled ? 0.7 : 1)
            .contentShape(.rect)
            .focused($isFocused, equals: focusableField)
            .disabled(isDisabled)
            .onTapGesture {
                viewModel.send(.setFocus(focusableField))
            }
            .onChange(of: viewModel.focus) {
                isFocused = $0
            }
            .onChange(of: isFocused) { focus in
                if let focus {
                    viewModel.send(.setFocus(focus))
                }
            }
            .accessibilityIdentifier(accessibilityIdentifier)
    }
}

// MARK: - Private Computed Properties

private extension TextFieldView {
    var bindingText: Binding<String> {
        Binding(
            get: { text },
            set: { viewModel.send(.setTextFieldText(focusableField, $0)) }
        )
    }

    var isDisabled: Bool {
        viewModel.isFieldDisabled(focusableField)
    }

    var isFieldFocused: Bool {
        isFocused == focusableField
    }

    var text: String {
        switch focusableField {
        case .totalBetSize:
            return viewModel.total.betSize
        case let .rowBetSize(id):
            return viewModel.row(for: id)?.betSize ?? ""
        case let .rowCoefficient(id):
            return viewModel.row(for: id)?.coefficient ?? ""
        }
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
        case let .rowBetSize(id):
            let displayIndex = viewModel.displayIndex(for: id) ?? 0
            return AccessibilityIdentifiers.Row.betSizeTextField(displayIndex)
        case let .rowCoefficient(id):
            let displayIndex = viewModel.displayIndex(for: id) ?? 0
            return AccessibilityIdentifiers.Row.coefficientTextField(displayIndex)
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

#Preview {
    TextFieldView(
        placeholder: SurebetCalculatorLocalizationKey.totalBetSize.localized,
        focusableField: .totalBetSize
    )
    .padding()
    .environmentObject(SurebetCalculatorViewModel())
}
