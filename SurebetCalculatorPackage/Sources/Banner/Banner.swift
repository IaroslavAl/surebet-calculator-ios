import SwiftUI

public enum Banner {
    // MARK: - Public Methods

    @MainActor
    public static var bannerView: some View {
        BannerView()
    }

    @MainActor
    public static func fullscreenBannerView(isPresented: Binding<Bool>) -> some View {
        FullscreenBannerView(isPresented: isPresented, service: Service())
    }

    @MainActor
    public static func fullscreenBannerView(isPresented: Binding<Bool>, service: BannerService) -> some View {
        FullscreenBannerView(isPresented: isPresented, service: service)
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
