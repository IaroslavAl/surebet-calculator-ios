import SwiftUI

public enum Banner {
    public static var bannerView: some View {
        BannerView()
    }

    public static func fullscreenBannerView(isPresented: Binding<Bool>) -> some View {
        FullscreenBannerView(isPresented: isPresented)
    }

    public static func fetchBanner() async throws {
        try await Service().fetchBannerAndImage()
    }

    public static var isBannerFullyCached: Bool {
        print("<< \(Service().isBannerFullyCached())")
        return Service().isBannerFullyCached()
    }
}
