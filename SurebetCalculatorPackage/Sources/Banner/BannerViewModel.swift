import AnalyticsManager
import Foundation

@MainActor
final class BannerViewModel: ObservableObject {
    // MARK: - State

    struct State {
        var isPresented: Bool
    }

    // MARK: - Properties

    @Published private(set) var state: State

    private let analyticsService: AnalyticsService
    private let urlOpener: URLOpener

    // MARK: - Initialization

    init(
        analyticsService: AnalyticsService = AnalyticsManager(),
        urlOpener: URLOpener = DefaultURLOpener()
    ) {
        self.state = State(isPresented: true)
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
    }

    // MARK: - Public Methods

    enum Action {
        case onAppear
        case tapBanner
        case tapClose
    }

    func send(_ action: Action) {
        switch action {
        case .onAppear:
            logBannerViewed()
        case .tapBanner:
            handleBannerTap()
        case .tapClose:
            handleCloseTap()
        }
    }
}

// MARK: - Private Methods

private extension BannerViewModel {
    func handleBannerTap() {
        urlOpener.open(BannerConstants.inlineBannerAffiliateURL)
        analyticsService.log(
            event: .bannerClicked(bannerId: BannerConstants.inlineBannerId, bannerType: .inline)
        )
    }

    func handleCloseTap() {
        state.isPresented = false
        analyticsService.log(
            event: .bannerClosed(bannerId: BannerConstants.inlineBannerId, bannerType: .inline)
        )
    }

    func logBannerViewed() {
        analyticsService.log(
            event: .bannerViewed(bannerId: BannerConstants.inlineBannerId, bannerType: .inline)
        )
    }
}
