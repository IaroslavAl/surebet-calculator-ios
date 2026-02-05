import SDWebImageSwiftUI
import SwiftUI
import DesignSystem

struct BannerView: View {
    // MARK: - Properties

    @StateObject private var viewModel: BannerViewModel

    // MARK: - Initialization

    init(viewModel: BannerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        if viewModel.state.isPresented {
            bannerContent
                .onAppear {
                    viewModel.send(.onAppear)
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
                viewModel.send(.tapBanner)
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
            .foregroundStyle(DesignSystem.Color.bannerCloseButtonInline)
            .padding(BannerConstants.inlineCloseButtonPadding)
            .contentShape(.rect)
            .onTapGesture {
                viewModel.send(.tapClose)
            }
    }

    var cornerRadius: CGFloat {
        isIPad
            ? BannerConstants.inlineBannerCornerRadiusiPad
            : BannerConstants.inlineBannerCornerRadiusiPhone
    }

    var imageURL: String {
        isIPad
            ? BannerConstants.inlineBannerImageURLiPad
            : BannerConstants.inlineBannerImageURLiPhone
    }
}

#Preview {
    BannerView(viewModel: BannerViewModel())
}
