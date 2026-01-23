import Foundation

/// Константы для модуля Banner
enum BannerConstants {
    // MARK: - URLs
    
    /// Базовый URL API для загрузки баннеров
    static let apiBaseURL = "http://api.surebet-calculator.ru"
    
    /// Резервный URL для баннера (если не указан в API)
    static let bannerFallbackURL = "https://1wfdtj.com/casino/list?open=register&p=jyy2"
    
    // MARK: - Network
    
    /// Таймаут для сетевых запросов (10 секунд)
    static let requestTimeout: TimeInterval = 10
    
    // MARK: - Delays
    
    /// Задержка перед закрытием баннера после открытия URL (500ms)
    static let bannerCloseDelay: UInt64 = 500_000_000
    
    // MARK: - Layout
    
    /// Размер кнопки закрытия баннера (40pt)
    static let closeButtonSize: CGFloat = 40
    
    /// Отступ для кнопки закрытия баннера (16pt)
    static let closeButtonPadding: CGFloat = 16
    
    /// Радиус скругления для fullscreen баннера на iPad (24pt)
    static let fullscreenBannerCornerRadiusiPad: CGFloat = 24
    
    /// Радиус скругления для fullscreen баннера на iPhone (16pt)
    static let fullscreenBannerCornerRadiusiPhone: CGFloat = 16
}
