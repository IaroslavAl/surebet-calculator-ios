import DesignSystem
import SwiftUI
import UIKit

struct SurveySheetView: View {
    @StateObject private var viewModel: SurveySheetViewModel
    @State private var resolvedDetents: Set<PresentationDetent> = [.medium, .large]
    @State private var didResolveDetents = false

    init(viewModel: SurveySheetViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            DesignSystem.Color.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                    header
                    fields
                    submitButton
                }
                .padding(.horizontal, DesignSystem.Spacing.large)
                .padding(.top, DesignSystem.Spacing.extraLarge)
                .padding(.bottom, DesignSystem.Spacing.large)
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: SurveyContentHeightPreferenceKey.self,
                            value: geometry.size.height
                        )
                    }
                )
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .onPreferenceChange(SurveyContentHeightPreferenceKey.self) { newValue in
            resolveDetentsIfNeeded(for: newValue)
        }
        .presentationDetents(resolvedDetents)
        .presentationDragIndicator(.visible)
    }
}

private extension SurveySheetView {
    func resolveDetentsIfNeeded(for contentHeight: CGFloat) {
        guard contentHeight > .zero else { return }
        guard !didResolveDetents else { return }
        resolvedDetents = adaptiveDetents(for: contentHeight)
        didResolveDetents = true
    }

    func adaptiveDetents(for contentHeight: CGFloat) -> Set<PresentationDetent> {
        let minimumHeight: CGFloat = 420
        let safeBottomInset: CGFloat = 34
        let targetHeight = max(minimumHeight, contentHeight + safeBottomInset)
        let fullScreenThreshold = maximumSheetHeight * 0.72

        if targetHeight >= fullScreenThreshold {
            return [.large]
        }

        return [.height(min(targetHeight.rounded(.up), fullScreenThreshold.rounded(.up)))]
    }

    var maximumSheetHeight: CGFloat {
        max(UIScreen.main.bounds.height - 120, 500)
    }

    var survey: SurveyModel { viewModel.state.survey }

    var header: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text(survey.title)
                .font(DesignSystem.Typography.title)
                .foregroundColor(DesignSystem.Color.textPrimary)

            Text(survey.body)
                .font(DesignSystem.Typography.description)
                .foregroundColor(DesignSystem.Color.textSecondary)
        }
    }

    var fields: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            ForEach(survey.fields) { field in
                SurveyFieldView(field: field, viewModel: viewModel)
            }
        }
    }

    var submitButton: some View {
        PrimaryActionButton(
            survey.submitButtonTitle,
            variant: .accent,
            size: .large
        ) {
            viewModel.send(.submitTapped)
        }
        .padding(.top, DesignSystem.Spacing.small)
    }
}

private struct SurveyFieldView: View {
    let field: SurveyField
    @ObservedObject private var viewModel: SurveySheetViewModel

    init(field: SurveyField, viewModel: SurveySheetViewModel) {
        self.field = field
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            title
            subtitle
            input
            validationError
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.surface)
        .cornerRadius(DesignSystem.Radius.medium)
        .overlay {
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .stroke(DesignSystem.Color.borderMuted, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }
}

private extension SurveyFieldView {
    var title: some View {
        HStack(spacing: DesignSystem.Spacing.small / 2) {
            Text(field.title)
                .font(DesignSystem.Typography.body.weight(.semibold))
                .foregroundColor(DesignSystem.Color.textPrimary)

            if field.isRequired {
                Text("*")
                    .font(DesignSystem.Typography.body.weight(.semibold))
                    .foregroundColor(DesignSystem.Color.error)
            }
        }
    }

    @ViewBuilder
    var subtitle: some View {
        if let subtitle = field.subtitle, !subtitle.isEmpty {
            Text(subtitle)
                .font(DesignSystem.Typography.label)
                .foregroundColor(DesignSystem.Color.textSecondary)
        }
    }

    @ViewBuilder
    var input: some View {
        switch field.type {
        case let .ratingScale(config):
            ratingScaleInput(config) { value in
                viewModel.send(.setRating(fieldID: field.id, value: value))
            }

        case let .textInput(config):
            textInput(config)

        case let .singleChoice(config):
            singleChoiceInput(config)

        case let .multiChoice(config):
            multiChoiceInput(config)

        case let .ratingWithComment(config):
            ratingWithCommentInput(config)
        }
    }

    @ViewBuilder
    var validationError: some View {
        if let error = viewModel.validationError(for: field.id) {
            Text(error.message)
                .font(DesignSystem.Typography.label)
                .foregroundColor(DesignSystem.Color.error)
        }
    }

    func ratingScaleInput(
        _ config: SurveyRatingScaleConfig,
        onSelect: @escaping (Int) -> Void
    ) -> some View {
        let values = config.values
        return LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 56), spacing: DesignSystem.Spacing.small)],
            spacing: DesignSystem.Spacing.small
        ) {
            ForEach(values, id: \.self) { value in
                let isSelected = viewModel.ratingValue(for: field.id) == value
                Button {
                    onSelect(value)
                } label: {
                    Text("\(value)")
                        .font(DesignSystem.Typography.body.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .foregroundColor(isSelected ? .white : DesignSystem.Color.textPrimary)
                        .background(isSelected ? DesignSystem.Color.accent : DesignSystem.Color.surfaceInput)
                        .cornerRadius(DesignSystem.Radius.small)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
        }
    }

    func textInput(_ config: SurveyTextInputConfig) -> some View {
        Group {
            if config.isMultiline {
                SurveyMultilineTextField(
                    text: Binding(
                        get: { viewModel.textValue(for: field.id) },
                        set: { viewModel.send(.setText(fieldID: field.id, value: $0)) }
                    ),
                    placeholder: config.placeholder
                )
                .frame(minHeight: 110)
            } else {
                TextField(
                    config.placeholder ?? "",
                    text: Binding(
                        get: { viewModel.textValue(for: field.id) },
                        set: { viewModel.send(.setText(fieldID: field.id, value: $0)) }
                    )
                )
                .textInputAutocapitalization(.sentences)
                .padding(DesignSystem.Spacing.small)
                .background(DesignSystem.Color.surfaceInput)
                .cornerRadius(DesignSystem.Radius.small)
            }
        }
    }

    func singleChoiceInput(_ config: SurveyChoiceConfig) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            ForEach(config.options) { option in
                SurveyChoiceRow(
                    title: option.title,
                    isSelected: viewModel.isOptionSelected(fieldID: field.id, optionID: option.id)
                ) {
                    viewModel.send(.selectSingleChoice(fieldID: field.id, optionID: option.id))
                }
            }
        }
    }

    func multiChoiceInput(_ config: SurveyChoiceConfig) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            ForEach(config.options) { option in
                SurveyChoiceRow(
                    title: option.title,
                    isSelected: viewModel.isOptionSelected(fieldID: field.id, optionID: option.id)
                ) {
                    viewModel.send(.toggleMultiChoice(fieldID: field.id, optionID: option.id))
                }
            }
        }
    }

    func ratingWithCommentInput(_ config: SurveyRatingWithCommentConfig) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            ratingScaleInput(
                SurveyRatingScaleConfig(
                    minValue: config.minValue,
                    maxValue: config.maxValue,
                    step: config.step
                )
            ) { value in
                viewModel.send(.setRatingWithCommentRating(fieldID: field.id, value: value))
            }

            SurveyMultilineTextField(
                text: Binding(
                    get: { viewModel.textValue(for: field.id) },
                    set: { viewModel.send(.setRatingWithCommentComment(fieldID: field.id, text: $0)) }
                ),
                placeholder: config.commentPlaceholder
            )
            .frame(minHeight: 110)
        }
    }
}

private struct SurveyChoiceRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.small) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? DesignSystem.Color.accent : DesignSystem.Color.textMuted)
                Text(title)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Color.textPrimary)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .background(isSelected ? DesignSystem.Color.accentSoft : DesignSystem.Color.surfaceInput)
            .cornerRadius(DesignSystem.Radius.small)
            .overlay {
                RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
                    .stroke(
                        isSelected ? DesignSystem.Color.accent : DesignSystem.Color.borderMuted,
                        lineWidth: 1
                    )
                    .allowsHitTesting(false)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct SurveyContentHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = .zero

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct SurveyMultilineTextField: View {
    @Binding var text: String
    let placeholder: String?
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .padding(.horizontal, DesignSystem.Spacing.small / 2)
                .padding(.vertical, DesignSystem.Spacing.small / 2)
                .focused($isFocused)
                .scrollContentBackground(.hidden)
                .background(DesignSystem.Color.surfaceInput)
                .cornerRadius(DesignSystem.Radius.small)

            if text.isEmpty, !isFocused, let placeholder, !placeholder.isEmpty {
                Text(placeholder)
                    .font(DesignSystem.Typography.description)
                    .foregroundColor(DesignSystem.Color.textMuted)
                    .padding(.top, DesignSystem.Spacing.small)
                    .padding(.leading, DesignSystem.Spacing.small)
                    .allowsHitTesting(false)
            }
        }
    }
}
