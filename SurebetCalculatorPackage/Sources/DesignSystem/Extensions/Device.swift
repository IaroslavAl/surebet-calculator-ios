import SwiftUI

/// Утилита для определения типа устройства.
public enum Device {
    /// Определяет, является ли текущее устройство iPad.
    /// Почему: UIDevice.current безопасен для чтения только на MainActor.
    @MainActor
    public static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    /// Nonisolated версия для использования из любого контекста.
    public nonisolated(unsafe) static var isIPadUnsafe: Bool {
        MainActor.assumeIsolated {
            UIDevice.current.userInterfaceIdiom == .pad
        }
    }
}

public extension View {
    /// Быстрый доступ к типу устройства из SwiftUI.
    var isIPad: Bool {
        Device.isIPadUnsafe
    }
}
