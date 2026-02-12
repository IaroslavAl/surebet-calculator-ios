import AnalyticsManager
import SwiftUI

public enum Banner {
    @MainActor
    public struct Dependencies {
        public let service: any BannerService
        public let analyticsService: any AnalyticsService
        public let urlOpener: any URLOpener

        public init(
            service: any BannerService,
            analyticsService: any AnalyticsService,
            urlOpener: any URLOpener
        ) {
            self.service = service
            self.analyticsService = analyticsService
            self.urlOpener = urlOpener
        }
    }

    // MARK: - Public Methods

    @MainActor
    public static func bannerView(dependencies: Dependencies) -> some View {
        BannerView(
            viewModel: BannerViewModel(
                analyticsService: dependencies.analyticsService,
                urlOpener: dependencies.urlOpener
            )
        )
    }

    @MainActor
    public static func fullscreenBannerView(
        isPresented: Binding<Bool>,
        dependencies: Dependencies
    ) -> some View {
        FullscreenBannerView(
            viewModel: FullscreenBannerViewModel(
                isPresented: PresentationBinding(
                    getValue: { isPresented.wrappedValue },
                    setValue: { isPresented.wrappedValue = $0 }
                ),
                service: dependencies.service,
                analyticsService: dependencies.analyticsService,
                urlOpener: dependencies.urlOpener
            )
        )
    }

    public static func fetchBanner(service: BannerService) async throws {
        try await service.fetchBannerAndImage()
    }

    public static func isBannerFullyCached(service: BannerService) -> Bool {
        service.isBannerFullyCached()
    }
}
