import SwiftUI

/// Утилита для определения типа устройства
enum Device {
    /// Определяет, является ли текущее устройство iPad
    /// UIDevice.current безопасен для чтения из любого контекста
    @MainActor
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    /// Nonisolated версия для использования из любого контекста
    nonisolated(unsafe) static var isIPadUnsafe: Bool {
        MainActor.assumeIsolated {
            UIDevice.current.userInterfaceIdiom == .pad
        }
    }
}

extension View {
    /// Определяет, является ли текущее устройство iPad
    public var isIPad: Bool {
        Device.isIPadUnsafe
    }
}
