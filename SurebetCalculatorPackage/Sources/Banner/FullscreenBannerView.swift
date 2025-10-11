//
//  FullscreenBannerView.swift
//  SurebetCalculatorPackage
//
//  Created by BELDIN Yaroslav on 11.10.2025.
//

import SwiftUI

struct FullscreenBannerView: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
            Image(.surp)
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
                            isPresented = false
                        }
                }
                .onTapGesture {
                    openURL(url)
                }
        }
    }
}

private extension FullscreenBannerView {
    var iPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    var cornerRadius: CGFloat { iPad ? 24 : 16 }
    var url: String { "https://1wfdtj.com/casino/list?open=register&p=jyy2" }

    func openURL(_ url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        Task {
            try await Task.sleep(nanoseconds: 500_000_000)
            isPresented = false
        }
    }
}
