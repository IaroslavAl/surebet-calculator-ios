//
//  FullscreenBannerView.swift
//  SurebetCalculatorPackage
//
//  Created by BELDIN Yaroslav on 11.10.2025.
//

import SwiftUI
import DesignSystem

struct FullscreenBannerView: View {
    // MARK: - Properties

    @StateObject private var viewModel: FullscreenBannerViewModel

    // MARK: - Initialization

    init(viewModel: FullscreenBannerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            DesignSystem.Color.bannerFullscreenBackground
            bannerImage
        }
        .onAppear {
            viewModel.send(.onAppear)
        }
    }
}

// MARK: - Private Methods

private extension FullscreenBannerView {
    @ViewBuilder
    var bannerImage: some View {
        if let bannerImage = viewModel.state.bannerImage {
            Image(uiImage: bannerImage)
                .resizable()
                .scaledToFit()
                .cornerRadius(cornerRadius)
                .overlay(alignment: .topTrailing) {
                    closeButton
                }
                .onTapGesture {
                    viewModel.send(.tapBanner)
                }
        }
    }

    var closeButton: some View {
        Image(systemName: "xmark.circle.fill")
            .resizable()
            .frame(width: BannerConstants.closeButtonSize, height: BannerConstants.closeButtonSize)
            .foregroundStyle(DesignSystem.Color.bannerCloseButtonFullscreen)
            .padding(BannerConstants.closeButtonPadding)
            .contentShape(.rect)
            .onTapGesture {
                viewModel.send(.tapClose)
            }
    }

    var cornerRadius: CGFloat {
        isIPad ? BannerConstants.fullscreenBannerCornerRadiusiPad : BannerConstants.fullscreenBannerCornerRadiusiPhone
    }
}

// MARK: - Preview

#Preview {
    FullscreenBannerView(
        viewModel: FullscreenBannerViewModel(
            isPresented: PresentationBinding.constant(true)
        )
    )
}
