//
//  Service.swift
//  SurebetCalculatorPackage
//
//  Created by BELDIN Yaroslav on 23.11.2025.
//

import Foundation
import OSLog

enum BannerError: Error, Sendable {
    case bannerNotFound
    case invalidImageURL
}

public struct Service: BannerService, @unchecked Sendable {
    // MARK: - Properties

    private let baseURL: URL
    private let session: URLSession
    private let defaults: UserDefaults
    private let fileManager: FileManager
    private let cacheDirectory: URL

    // MARK: - Initialization

    public init(
        baseURL: URL? = nil,
        session: URLSession = .shared,
        defaults: UserDefaults = .standard,
        fileManager: FileManager = .default,
        cacheDirectory: URL? = nil
    ) {
        if let baseURL = baseURL {
            self.baseURL = baseURL
        } else {
            guard let url = URL(string: BannerConstants.apiBaseURL) else {
                fatalError("Invalid base URL: \(BannerConstants.apiBaseURL)")
            }
            self.baseURL = url
        }
        self.session = session
        self.defaults = defaults
        self.fileManager = fileManager
        if let cacheDirectory = cacheDirectory {
            self.cacheDirectory = cacheDirectory
        } else {
            let baseCache = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
            let resolvedBase = baseCache ?? fileManager.temporaryDirectory
            self.cacheDirectory = resolvedBase.appendingPathComponent(
                BannerConstants.cacheDirectoryName,
                isDirectory: true
            )
        }
    }

    // MARK: - Public Methods

    public func fetchBannerAndImage() async throws {
        BannerLogger.service.debug("Запрос баннера и картинки начат")

        do {
            let banner = try await fetchBanner()

            guard !banner.imageURL.absoluteString.isEmpty else {
                BannerLogger.service.error("Баннер содержит пустой imageURL — очищаем кэш")
                clearAllBannerData()
                throw BannerError.invalidImageURL
            }

            let storedImageURL = getStoredBannerImageURL()
            BannerLogger.service.debug(
                "Текущий URL сохранённой картинки: \(storedImageURL?.absoluteString ?? "nil", privacy: .public)"
            )
            BannerLogger.service.debug(
                "URL картинки из баннера: \(banner.imageURL.absoluteString, privacy: .public)"
            )

            if storedImageURL != banner.imageURL || getStoredBannerImageData() == nil {
                BannerLogger.service.debug("URL изменился, отсутствует или нет данных — скачиваем новую картинку…")
                try await downloadImage(from: banner.imageURL)
            } else {
                BannerLogger.service.debug("URL совпадает и данные есть — скачивание картинки не требуется")
            }

            BannerLogger.service.info("Запрос баннера и картинки завершён")
        } catch {
            BannerLogger.service.error(
                "Ошибка загрузки: \(error.localizedDescription, privacy: .public). Очищаем кэш баннера и картинки"
            )
            clearAllBannerData()
            throw error
        }
    }

    public func fetchBanner() async throws -> BannerModel {
        let url = baseURL.appendingPathComponent("banner")
        BannerLogger.service.debug("Отправляем GET \(url.absoluteString, privacy: .public)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = BannerConstants.requestTimeout

        let (data, response) = try await session.data(for: request)
        BannerLogger.service.debug("Получен ответ на баннер")

        guard let httpResponse = response as? HTTPURLResponse else {
            BannerLogger.service.error("Ошибка: ответ не HTTPURLResponse")
            throw URLError(.badServerResponse)
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            BannerLogger.service.error("Ошибка: код \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }

        guard !data.isEmpty else {
            BannerLogger.service.warning("Ответ пустой — баннер отсутствует. Очищаем кэш")
            clearAllBannerData()
            throw BannerError.bannerNotFound
        }

        let decoder = JSONDecoder()
        let banner = try decoder.decode(BannerModel.self, from: data)

        BannerLogger.service.info("Баннер успешно декодирован")
        saveBannerToDefaults(banner)

        return banner
    }

    public func saveBannerToDefaults(_ banner: BannerModel) {
        BannerLogger.service.debug("Сохранение баннера в UserDefaults…")
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(banner) {
            defaults.set(data, forKey: UserDefaultsKeys.banner)
            BannerLogger.service.debug("Баннер сохранён")
        } else {
            BannerLogger.service.error("Не удалось закодировать баннер")
        }
    }

    public func getBannerFromDefaults() -> BannerModel? {
        BannerLogger.service.debug("Чтение баннера из UserDefaults")
        guard let data = defaults.data(forKey: UserDefaultsKeys.banner) else {
            BannerLogger.service.debug("Баннер не найден в UserDefaults")
            return nil
        }

        let decoder = JSONDecoder()
        let banner = try? decoder.decode(BannerModel.self, from: data)
        BannerLogger.service.debug("Прочитанный баннер: \(banner != nil ? "найден" : "не найден", privacy: .public)")
        return banner
    }

    public func clearBannerFromDefaults() {
        BannerLogger.service.debug("Удаление баннера из UserDefaults")
        defaults.removeObject(forKey: UserDefaultsKeys.banner)
    }

    public func downloadImage(from url: URL) async throws {
        BannerLogger.service.debug("Скачивание картинки: \(url.absoluteString, privacy: .public)")

        // Используем URLRequest вместо прямого URL для совместимости с MockURLProtocol
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = BannerConstants.requestTimeout

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            BannerLogger.service.error("Ошибка: ответ не HTTPURLResponse")
            throw URLError(.badServerResponse)
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            BannerLogger.service.error("Ошибка скачивания: код \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }

        guard !data.isEmpty else {
            BannerLogger.service.warning("Получены пустые данные изображения — очищаем кэш")
            clearAllBannerData()
            throw URLError(.cannotDecodeContentData)
        }

        saveBannerImageData(data, imageURL: url)
        BannerLogger.service.info("Картинка успешно скачана и сохранена")
    }

    func saveBannerImageData(_ data: Data, imageURL: URL) {
        BannerLogger.service.debug("Сохранение картинки и URL в кэш")
        saveBannerImageDataToDisk(data)
        defaults.removeObject(forKey: UserDefaultsKeys.bannerImageData)
        defaults.set(imageURL.absoluteString, forKey: UserDefaultsKeys.bannerImageURLString)
    }

    public func getStoredBannerImageData() -> Data? {
        BannerLogger.service.debug("Получение картинки из кэша")
        if let cachedData = loadBannerImageDataFromDisk() {
            BannerLogger.service.debug("Картинка найдена в кэше: true")
            return cachedData
        }

        if let legacyData = defaults.data(forKey: UserDefaultsKeys.bannerImageData) {
            BannerLogger.service.debug("Картинка найдена в UserDefaults — переносим в кэш")
            saveBannerImageDataToDisk(legacyData)
            defaults.removeObject(forKey: UserDefaultsKeys.bannerImageData)
            return legacyData
        }

        BannerLogger.service.debug("Картинка найдена в кэше: false")
        return nil
    }

    public func getStoredBannerImageURL() -> URL? {
        BannerLogger.service.debug("Получение URL картинки из UserDefaults")
        guard let urlString = defaults.string(forKey: UserDefaultsKeys.bannerImageURLString) else {
            BannerLogger.service.debug("URL картинки не найден")
            return nil
        }
        let url = URL(string: urlString)
        BannerLogger.service.debug("URL картинки: \(url?.absoluteString ?? "nil", privacy: .public)")
        return url
    }

    public func isBannerFullyCached() -> Bool {
        BannerLogger.service.debug("Проверка полного кэша баннера и картинки")
        guard getBannerFromDefaults() != nil else {
            BannerLogger.service.debug("Баннер отсутствует в кэше")
            return false
        }

        guard hasCachedImageFile || migrateLegacyImageIfNeeded() else {
            BannerLogger.service.debug("Картинка отсутствует в кэше")
            return false
        }

        guard getStoredBannerImageURL() != nil else {
            BannerLogger.service.debug("URL картинки отсутствует в кэше")
            return false
        }

        BannerLogger.service.debug("Кэш баннера и картинки полный")
        return true
    }

    // MARK: - Private Methods

    private func clearAllBannerData() {
        BannerLogger.service.debug("Полная очистка данных баннера и картинки из кэша")
        defaults.removeObject(forKey: UserDefaultsKeys.banner)
        defaults.removeObject(forKey: UserDefaultsKeys.bannerImageData)
        defaults.removeObject(forKey: UserDefaultsKeys.bannerImageURLString)
        removeBannerImageFileIfNeeded()
    }

    private var bannerImageFileURL: URL {
        cacheDirectory.appendingPathComponent(BannerConstants.cachedImageFilename)
    }

    private var hasCachedImageFile: Bool {
        fileManager.fileExists(atPath: bannerImageFileURL.path)
    }

    private func ensureCacheDirectoryExists() throws {
        guard !fileManager.fileExists(atPath: cacheDirectory.path) else { return }
        try fileManager.createDirectory(
            at: cacheDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }

    private func saveBannerImageDataToDisk(_ data: Data) {
        do {
            try ensureCacheDirectoryExists()
            try data.write(to: bannerImageFileURL, options: [.atomic])
        } catch {
            let errorDescription = error.localizedDescription
            BannerLogger.service.error(
                "Не удалось сохранить картинку в кэш: \(errorDescription, privacy: .public)"
            )
        }
    }

    private func loadBannerImageDataFromDisk() -> Data? {
        guard hasCachedImageFile else { return nil }
        return try? Data(contentsOf: bannerImageFileURL)
    }

    private func migrateLegacyImageIfNeeded() -> Bool {
        guard !hasCachedImageFile else { return true }
        guard let legacyData = defaults.data(forKey: UserDefaultsKeys.bannerImageData) else {
            return false
        }
        BannerLogger.service.debug("Картинка найдена в UserDefaults — переносим в кэш")
        saveBannerImageDataToDisk(legacyData)
        defaults.removeObject(forKey: UserDefaultsKeys.bannerImageData)
        return true
    }

    private func removeBannerImageFileIfNeeded() {
        guard hasCachedImageFile else { return }
        try? fileManager.removeItem(at: bannerImageFileURL)
    }
}
