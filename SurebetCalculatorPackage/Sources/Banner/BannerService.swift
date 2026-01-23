import Foundation

/// Протокол для сервиса работы с баннерами.
/// Обеспечивает инверсию зависимостей и позволяет легко тестировать компоненты.
public protocol BannerService: Sendable {
    /// Загружает баннер и изображение с сервера.
    func fetchBannerAndImage() async throws

    /// Загружает баннер с сервера.
    /// - Returns: Модель баннера.
    func fetchBanner() async throws -> BannerModel

    /// Сохраняет баннер в UserDefaults.
    /// - Parameter banner: Модель баннера для сохранения.
    func saveBannerToDefaults(_ banner: BannerModel)

    /// Получает баннер из UserDefaults.
    /// - Returns: Модель баннера или nil, если баннер не найден.
    func getBannerFromDefaults() -> BannerModel?

    /// Удаляет баннер из UserDefaults.
    func clearBannerFromDefaults()

    /// Скачивает изображение по указанному URL.
    /// - Parameter url: URL изображения.
    func downloadImage(from url: URL) async throws

    /// Получает сохраненные данные изображения баннера.
    /// - Returns: Данные изображения или nil, если данные не найдены.
    func getStoredBannerImageData() -> Data?

    /// Получает сохраненный URL изображения баннера.
    /// - Returns: URL изображения или nil, если URL не найден.
    func getStoredBannerImageURL() -> URL?

    /// Проверяет, полностью ли закэшированы баннер и изображение.
    /// - Returns: true, если баннер и изображение полностью закэшированы.
    func isBannerFullyCached() -> Bool
}
