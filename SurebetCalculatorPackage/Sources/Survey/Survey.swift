import SwiftUI

public enum Survey {
    @MainActor
    public static func sheet(
        survey: SurveyModel,
        onSubmit: @escaping (SurveySubmission) -> Void,
        onClose: @escaping () -> Void
    ) -> some View {
        SurveySheetView(
            viewModel: SurveySheetViewModel(
                survey: survey,
                onSubmit: onSubmit,
                onClose: onClose
            )
        )
    }
}
