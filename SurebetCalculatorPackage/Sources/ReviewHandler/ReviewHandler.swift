import StoreKit
import SwiftUI

@MainActor
public final class ReviewHandler {
    /// Запрашивает отзыв пользователя с задержкой в 1 секунду
    /// - Note: Метод должен вызываться из контекста MainActor
    public static func requestReview() async {
        try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
        
        if let scene = UIApplication.shared.connectedScenes.first(
            where: {
                $0.activationState == .foregroundActive
            }
        ) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
