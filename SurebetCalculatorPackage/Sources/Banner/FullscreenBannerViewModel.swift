import AnalyticsManager
import Foundation

@MainActor
final class FullscreenBannerViewModel: ObservableObject {
    // MARK: - State

    struct State {
        var isPresented: Bool
        var bannerImageData: Data?
        var bannerId: String?
        var actionURL: URL?
    }

    // MARK: - Properties

    @Published private(set) var state: State

    private let service: BannerService
    private let analyticsService: AnalyticsService
    private let urlOpener: URLOpener
    private let isPresented: PresentationBinding

    // MARK: - Initialization

    init(
        isPresented: PresentationBinding,
        service: BannerService = Service(),
        analyticsService: AnalyticsService = AnalyticsManager(),
        urlOpener: URLOpener = DefaultURLOpener()
    ) {
        self.state = State(
            isPresented: isPresented.value,
            bannerImageData: nil,
            bannerId: nil,
            actionURL: nil
        )
        self.isPresented = isPresented
        self.service = service
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
    }

    // MARK: - Public Methods

    enum Action {
        case onAppear
        case tapClose
        case tapBanner
    }

    func send(_ action: Action) {
        switch action {
        case .onAppear:
            loadBannerIfNeeded()
            logBannerViewed()
        case .tapClose:
            handleCloseTap()
        case .tapBanner:
            handleBannerTap()
        }
    }
}

// MARK: - Private Methods

private extension FullscreenBannerViewModel {
    func loadBannerIfNeeded() {
        guard state.bannerImageData == nil else { return }
        state.bannerImageData = service.getStoredBannerImageData()
        if let banner = service.getBannerFromDefaults() {
            state.bannerId = banner.id
            state.actionURL = banner.actionURL
        }
    }

    func handleCloseTap() {
        if let bannerId = state.bannerId {
            analyticsService.log(event: .bannerClosed(bannerId: bannerId, bannerType: .fullscreen))
        }
        updatePresented(false)
    }

    func handleBannerTap() {
        guard let bannerId = state.bannerId, let actionURL = state.actionURL else {
            updatePresented(false)
            return
        }
        analyticsService.log(event: .bannerClicked(bannerId: bannerId, bannerType: .fullscreen))
        urlOpener.open(actionURL)
        Task {
            try? await Task.sleep(nanoseconds: BannerConstants.bannerCloseDelay)
            updatePresented(false)
        }
    }

    func logBannerViewed() {
        if let bannerId = state.bannerId {
            analyticsService.log(event: .bannerViewed(bannerId: bannerId, bannerType: .fullscreen))
        }
    }

    func updatePresented(_ isPresented: Bool) {
        state.isPresented = isPresented
        self.isPresented.value = isPresented
    }
}
