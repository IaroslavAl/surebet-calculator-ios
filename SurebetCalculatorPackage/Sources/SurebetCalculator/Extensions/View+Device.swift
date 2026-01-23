import SwiftUI

/// Глобальная переменная для определения типа устройства
var isIPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
}

extension View {
    /// Определяет, является ли текущее устройство iPad
    var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}
