//
//  FullscreenBannerView.swift
//  SurebetCalculatorPackage
//
//  Created by BELDIN Yaroslav on 11.10.2025.
//

import SwiftUI
import AnalyticsManager

struct FullscreenBannerView: View {
    // MARK: - Properties

    @Binding var isPresented: Bool

    private let service: BannerService
    private let analyticsService: AnalyticsService

    // MARK: - Initialization

    @MainActor
    init(
        isPresented: Binding<Bool>,
        service: BannerService = Service(),
        analyticsService: AnalyticsService = AnalyticsManager()
    ) {
        self._isPresented = isPresented
        self.service = service
        self.analyticsService = analyticsService
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
            bannerImage
        }
    }
}

// MARK: - Private Methods

private extension FullscreenBannerView {
    @ViewBuilder
    var bannerImage: some View {
        if let imageData = service.getStoredBannerImageData(),
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .cornerRadius(cornerRadius)
                .overlay(alignment: .topTrailing) {
                    closeButton
                }
                .onTapGesture {
                    handleBannerTap()
                }
        }
    }

    var closeButton: some View {
        Image(systemName: "xmark.circle.fill")
            .resizable()
            .frame(width: BannerConstants.closeButtonSize, height: BannerConstants.closeButtonSize)
            .foregroundStyle(.white.opacity(0.5))
            .padding(BannerConstants.closeButtonPadding)
            .contentShape(.rect)
            .onTapGesture {
                handleCloseTap()
            }
    }

    func handleCloseTap() {
        if let banner = service.getBannerFromDefaults() {
            analyticsService.log(name: "ClosedBanner(\(banner.id)", parameters: nil)
        }
        isPresented = false
    }

    func handleBannerTap() {
        if let banner = service.getBannerFromDefaults() {
            analyticsService.log(name: "OpenedBanner(\(banner.id)", parameters: nil)
            openURL(banner.actionURL)
        } else {
            isPresented = false
        }
    }

    var iPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    var cornerRadius: CGFloat {
        iPad ? BannerConstants.fullscreenBannerCornerRadiusiPad : BannerConstants.fullscreenBannerCornerRadiusiPhone
    }
    var url: String { BannerConstants.bannerFallbackURL }

    func openURL(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        Task {
            try await Task.sleep(nanoseconds: BannerConstants.bannerCloseDelay)
            isPresented = false
        }
    }
}
