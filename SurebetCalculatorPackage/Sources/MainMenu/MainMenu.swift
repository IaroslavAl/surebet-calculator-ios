import SwiftUI

public enum MainMenuSection: String, Sendable {
    case calculator
    case settings
    case instructions
}

public enum MainMenuRoute: Hashable, Sendable {
    case section(MainMenuSection)
    case disableAds
}

public enum MainMenu {
    @MainActor
    public static func view(
        onRouteRequested: @escaping (MainMenuRoute) -> Void
    ) -> some View {
        MainMenuView(
            onRouteRequested: onRouteRequested
        )
    }

    @MainActor
    public static func instructionsView() -> some View {
        MenuInstructionsView()
    }

    @MainActor
    public static func disableAdsPlaceholderView() -> some View {
        MenuPlaceholderView(
            titleKey: .menuDisableAdsTitle,
            messageKey: .menuDisableAdsDescription,
            systemImage: "nosign"
        )
    }
}
