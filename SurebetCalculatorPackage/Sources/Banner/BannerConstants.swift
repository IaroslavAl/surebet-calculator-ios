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

    // MARK: - Cache

    /// Директория кэша баннеров в Caches.
    static let cacheDirectoryName = "BannerCache"

    /// Имя файла для изображения баннера в кэше.
    static let cachedImageFilename = "banner_image.data"

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

    // MARK: - Inline Banner

    /// Радиус скругления для inline баннера на iPad (15pt)
    static let inlineBannerCornerRadiusiPad: CGFloat = 15

    /// Радиус скругления для inline баннера на iPhone (10pt)
    static let inlineBannerCornerRadiusiPhone: CGFloat = 10

    /// Размер кнопки закрытия inline баннера (20pt)
    static let inlineCloseButtonSize: CGFloat = 20

    /// Отступ для кнопки закрытия inline баннера (8pt)
    static let inlineCloseButtonPadding: CGFloat = 8

    /// URL партнёрской ссылки для inline баннера
    static let inlineBannerAffiliateURL = "https://www.rebelbetting.com/valuebetting?x=surebet_profit&a_bid=c3ecdf4b"

    /// URL изображения inline баннера для iPad
    static let inlineBannerImageURLiPad = "https://affiliates.rebelbetting.com/accounts/default1/banners/1ab8d504.jpg"

    /// URL изображения inline баннера для iPhone
    static let inlineBannerImageURLiPhone = "https://affiliates.rebelbetting.com/accounts/default1/banners/c3ecdf4b.gif"

    /// Идентификатор inline баннера для аналитики
    static let inlineBannerId = "rebel_betting_inline"
}
