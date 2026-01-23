import StoreKit
import SwiftUI

@MainActor
public final class ReviewHandler: ReviewService {
    // MARK: - Initialization

    /// Публичный инициализатор
    public init() {}

    // MARK: - Public Methods

    /// Запрашивает отзыв пользователя с задержкой в 1 секунду
    /// - Note: Метод должен вызываться из контекста MainActor
    public func requestReview() async {
        try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)

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
        let handler = ReviewHandler()
        await handler.requestReview()
    }
}
