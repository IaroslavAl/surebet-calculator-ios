import StoreKit
import SwiftUI

@MainActor
public final class ReviewHandler: ReviewService {
    // MARK: - Initialization

    private let delay: Delay

    /// Публичный инициализатор
    public init(delay: Delay = SystemDelay()) {
        self.delay = delay
    }

    @MainActor
    static var defaultDelay: Delay = SystemDelay()

    // MARK: - Public Methods

    /// Запрашивает отзыв пользователя с задержкой в 1 секунду
    /// - Note: Метод должен вызываться из контекста MainActor
    public func requestReview() async {
        await delay.sleep(nanoseconds: ReviewConstants.reviewRequestDelay)

        if let scene = UIApplication.shared.connectedScenes.first(
            where: {
                $0.activationState == .foregroundActive
            }
        ) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    /// Статический метод для обратной совместимости
    public static func requestReview() async {
        let handler = ReviewHandler(delay: defaultDelay)
        await handler.requestReview()
    }
}
