//
//  FullscreenBannerView.swift
//  SurebetCalculatorPackage
//
//  Created by BELDIN Yaroslav on 11.10.2025.
//

import SwiftUI
import AnalyticsManager

struct FullscreenBannerView: View {
    @Binding var isPresented: Bool

    private let service: BannerService
    private let analyticsService: AnalyticsService

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

    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
            bannerImage
        }
    }
}

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
            .frame(width: 40, height: 40)
            .foregroundStyle(.white.opacity(0.5))
            .padding(16)
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
    var cornerRadius: CGFloat { iPad ? 24 : 16 }
    var url: String { "https://1wfdtj.com/casino/list?open=register&p=jyy2" }

    func openURL(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        Task {
            try await Task.sleep(nanoseconds: 500_000_000)
            isPresented = false
        }
    }
}
