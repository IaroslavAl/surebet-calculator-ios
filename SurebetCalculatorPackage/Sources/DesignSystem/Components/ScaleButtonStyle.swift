import SwiftUI

/// Стиль кнопки с анимацией масштабирования при нажатии.
public struct ScaleButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

public extension ButtonStyle where Self == ScaleButtonStyle {
    /// Стиль кнопки с анимацией масштабирования при нажатии.
    static var scale: ScaleButtonStyle {
        ScaleButtonStyle()
    }
}
