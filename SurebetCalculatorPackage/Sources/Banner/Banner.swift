import AnalyticsManager
import SwiftUI

public enum Banner {
    // MARK: - Public Methods

    @MainActor
    public static var bannerView: some View {
        BannerView(
            viewModel: BannerViewModel(
                analyticsService: AnalyticsManager(),
                urlOpener: DefaultURLOpener()
            )
        )
    }

    @MainActor
    public static func fullscreenBannerView(isPresented: Binding<Bool>) -> some View {
        FullscreenBannerView(
            viewModel: FullscreenBannerViewModel(
                isPresented: PresentationBinding(
                    getValue: { isPresented.wrappedValue },
                    setValue: { isPresented.wrappedValue = $0 }
                ),
                service: Service(),
                analyticsService: AnalyticsManager(),
                urlOpener: DefaultURLOpener()
            )
        )
    }

    @MainActor
    public static func fullscreenBannerView(isPresented: Binding<Bool>, service: BannerService) -> some View {
        FullscreenBannerView(
            viewModel: FullscreenBannerViewModel(
                isPresented: PresentationBinding(
                    getValue: { isPresented.wrappedValue },
                    setValue: { isPresented.wrappedValue = $0 }
                ),
                service: service,
                analyticsService: AnalyticsManager(),
                urlOpener: DefaultURLOpener()
            )
        )
    }

    public static func fetchBanner() async throws {
        try await Service().fetchBannerAndImage()
    }

    public static func fetchBanner(service: BannerService) async throws {
        try await service.fetchBannerAndImage()
    }

    public static var isBannerFullyCached: Bool {
        Service().isBannerFullyCached()
    }

    public static func isBannerFullyCached(service: BannerService) -> Bool {
        service.isBannerFullyCached()
    }
}
