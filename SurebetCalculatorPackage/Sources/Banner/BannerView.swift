import AnalyticsManager
import SDWebImageSwiftUI
import SwiftUI

struct BannerView: View {
    // MARK: - Properties

    let link = "https://www.rebelbetting.com/valuebetting?x=surebet_profit&a_bid=c3ecdf4b"

    @State
    private var isPresented: Bool = true

    // MARK: - Body

    var body: some View {
        if isPresented {
            bannerContent
        }
    }
}

// MARK: - Private Methods

private extension BannerView {
    var bannerContent: some View {
        WebImage(url: .init(string: url))
            .resizable()
            .scaledToFit()
            .cornerRadius(cornerRadius)
            .onTapGesture {
                handleBannerTap()
            }
            .overlay(alignment: .topTrailing) {
                closeButton
            }
    }

    var closeButton: some View {
        Image(systemName: "xmark.circle.fill")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundStyle(.black.opacity(0.25))
            .padding(8)
            .contentShape(.rect)
            .onTapGesture {
                handleCloseTap()
            }
    }

    func handleBannerTap() {
        openURL(link)
        AnalyticsManager.log(name: "ClickingOnAnAdvertisement")
    }

    func handleCloseTap() {
        isPresented = false
        AnalyticsManager.log(name: "CloseBanner")
    }

    var iPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    var cornerRadius: CGFloat { iPad ? 15 : 10 }

    func openURL(_ url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    var url: String {
        if iPad {
            "https://affiliates.rebelbetting.com/accounts/default1/banners/1ab8d504.jpg"
        } else {
            "https://affiliates.rebelbetting.com/accounts/default1/banners/c3ecdf4b.gif"
        }
    }
}

#Preview {
    BannerView()
}
