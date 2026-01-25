import AnalyticsManager
import SDWebImageSwiftUI
import SwiftUI

struct BannerView: View {
    // MARK: - Properties

    private let analyticsService: AnalyticsService

    @State
    private var isPresented: Bool = true

    // MARK: - Initialization

    @MainActor
    init(analyticsService: AnalyticsService = AnalyticsManager()) {
        self.analyticsService = analyticsService
    }

    // MARK: - Body

    var body: some View {
        if isPresented {
            bannerContent
                .onAppear {
                    logBannerViewed()
                }
        }
    }
}

// MARK: - Private Methods

private extension BannerView {
    var bannerContent: some View {
        WebImage(url: .init(string: imageURL))
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
            .frame(
                width: BannerConstants.inlineCloseButtonSize,
                height: BannerConstants.inlineCloseButtonSize
            )
            .foregroundStyle(BannerColors.closeButtonInline)
            .padding(BannerConstants.inlineCloseButtonPadding)
            .contentShape(.rect)
            .onTapGesture {
                handleCloseTap()
            }
    }

    func handleBannerTap() {
        openURL(BannerConstants.inlineBannerAffiliateURL)
        analyticsService.log(
            event: .bannerClicked(bannerId: BannerConstants.inlineBannerId, bannerType: .inline)
        )
    }

    func handleCloseTap() {
        isPresented = false
        analyticsService.log(
            event: .bannerClosed(bannerId: BannerConstants.inlineBannerId, bannerType: .inline)
        )
    }

    func logBannerViewed() {
        analyticsService.log(
            event: .bannerViewed(bannerId: BannerConstants.inlineBannerId, bannerType: .inline)
        )
    }

    var cornerRadius: CGFloat {
        isIPad
            ? BannerConstants.inlineBannerCornerRadiusiPad
            : BannerConstants.inlineBannerCornerRadiusiPhone
    }

    func openURL(_ url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    var imageURL: String {
        isIPad
            ? BannerConstants.inlineBannerImageURLiPad
            : BannerConstants.inlineBannerImageURLiPhone
    }
}

#Preview {
    BannerView()
}
