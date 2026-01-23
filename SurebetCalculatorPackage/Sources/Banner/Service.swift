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

struct Service: BannerService, @unchecked Sendable {
    // MARK: - Properties

    private let baseURL: URL
    private let session: URLSession
    private let defaults: UserDefaults

    // MARK: - Initialization

    init(
        session: URLSession = .shared,
        defaults: UserDefaults = .standard
    ) {
        guard let url = URL(string: BannerConstants.apiBaseURL) else {
            fatalError("Invalid base URL: \(BannerConstants.apiBaseURL)")
        }
        self.baseURL = url
        self.session = session
        self.defaults = defaults
    }

    // MARK: - Public Methods

    func fetchBannerAndImage() async throws {
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

    func fetchBanner() async throws -> BannerModel {
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

    func saveBannerToDefaults(_ banner: BannerModel) {
        BannerLogger.service.debug("Сохранение баннера в UserDefaults…")
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(banner) {
            defaults.set(data, forKey: UserDefaultsKeys.banner)
            BannerLogger.service.debug("Баннер сохранён")
        } else {
            BannerLogger.service.error("Не удалось закодировать баннер")
        }
    }

    func getBannerFromDefaults() -> BannerModel? {
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

    func clearBannerFromDefaults() {
        BannerLogger.service.debug("Удаление баннера из UserDefaults")
        defaults.removeObject(forKey: UserDefaultsKeys.banner)
    }

    func downloadImage(from url: URL) async throws {
        BannerLogger.service.debug("Скачивание картинки: \(url.absoluteString, privacy: .public)")
        let (data, response) = try await session.data(from: url)

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
        BannerLogger.service.debug("Сохранение картинки и URL в UserDefaults")
        defaults.set(data, forKey: UserDefaultsKeys.bannerImageData)
        defaults.set(imageURL.absoluteString, forKey: UserDefaultsKeys.bannerImageURLString)
    }

    func getStoredBannerImageData() -> Data? {
        BannerLogger.service.debug("Получение картинки из UserDefaults")
        let data = defaults.data(forKey: UserDefaultsKeys.bannerImageData)
        BannerLogger.service.debug("Картинка найдена: \(data != nil, privacy: .public)")
        return data
    }

    func getStoredBannerImageURL() -> URL? {
        BannerLogger.service.debug("Получение URL картинки из UserDefaults")
        guard let urlString = defaults.string(forKey: UserDefaultsKeys.bannerImageURLString) else {
            BannerLogger.service.debug("URL картинки не найден")
            return nil
        }
        let url = URL(string: urlString)
        BannerLogger.service.debug("URL картинки: \(url?.absoluteString ?? "nil", privacy: .public)")
        return url
    }

    func isBannerFullyCached() -> Bool {
        BannerLogger.service.debug("Проверка полного кэша баннера и картинки")
        guard getBannerFromDefaults() != nil else {
            BannerLogger.service.debug("Баннер отсутствует в кэше")
            return false
        }

        guard getStoredBannerImageData() != nil else {
            BannerLogger.service.debug("Картинка отсутствует в кэше")
            return false
        }

        BannerLogger.service.debug("Кэш баннера и картинки полный")
        return true
    }

    // MARK: - Private Methods

    private func clearAllBannerData() {
        BannerLogger.service.debug("Полная очистка данных баннера и картинки из UserDefaults")
        defaults.removeObject(forKey: UserDefaultsKeys.banner)
        defaults.removeObject(forKey: UserDefaultsKeys.bannerImageData)
        defaults.removeObject(forKey: UserDefaultsKeys.bannerImageURLString)
    }
}
