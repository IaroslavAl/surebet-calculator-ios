import SwiftUI

/// Утилита для определения типа устройства
enum Device {
    /// Определяет, является ли текущее устройство iPad
    nonisolated(unsafe) static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}

extension View {
    /// Определяет, является ли текущее устройство iPad
    var isIPad: Bool {
        Device.isIPad
    }
}
