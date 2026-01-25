import SwiftUI

/// Стиль кнопки с анимацией масштабирования при нажатии
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(AppConstants.Animations.quickInteraction, value: configuration.isPressed)
    }
}
