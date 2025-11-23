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

    private let serivce = Service()

    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
            if let imageData = serivce.getStoredBannerImageData(), let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(cornerRadius)
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.white.opacity(0.5))
                            .padding(16)
                            .contentShape(.rect)
                            .onTapGesture {
                                if let banner = serivce.getBannerFromDefaults() {
                                    AnalyticsManager.log(name: "ClosedBanner(\(banner.id)")
                                }
                                isPresented = false
                            }
                    }
                    .onTapGesture {
                        if let banner = serivce.getBannerFromDefaults() {
                            AnalyticsManager.log(name: "OpenedBanner(\(banner.id)")
                            openURL(banner.actionURL)
                        } else {
                            isPresented = false
                        }
                    }
            }
        }
    }
}

private extension FullscreenBannerView {
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
