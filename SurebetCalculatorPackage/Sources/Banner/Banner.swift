import SwiftUI

public enum Banner {
    public static var bannerView: some View {
        BannerView()
    }

    public static func fullscreenBannerView(isPresented: Binding<Bool>) -> some View {
        FullscreenBannerView(isPresented: isPresented)
    }
}
