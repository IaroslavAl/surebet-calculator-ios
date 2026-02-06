import AnalyticsManager
import Foundation
import UIKit

@MainActor
final class FullscreenBannerViewModel: ObservableObject {
    // MARK: - State

    struct State {
        var isPresented: Bool
        var bannerImage: UIImage?
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
            bannerImage: nil,
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
    struct BannerImage: @unchecked Sendable {
        let image: UIImage
    }

    func loadBannerIfNeeded() {
        guard state.bannerImage == nil else { return }
        Task { @MainActor [weak self] in
            guard let self else { return }
            let service = self.service
            let loadTask = Task.detached(priority: .utility) {
                let imageData = service.getStoredBannerImageData()
                let banner = service.getBannerFromDefaults()
                var image: BannerImage?
                if let imageData, let uiImage = UIImage(data: imageData) {
                    let preparedImage = uiImage.preparingForDisplay() ?? uiImage
                    image = BannerImage(image: preparedImage)
                }
                return (image, banner)
            }
            let (bannerImage, banner) = await loadTask.value
            if self.state.bannerImage == nil {
                self.state.bannerImage = bannerImage?.image
            }
            if let banner {
                self.state.bannerId = banner.id
                self.state.actionURL = banner.actionURL
            }
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
