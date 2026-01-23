//
//  Service.swift
//  SurebetCalculatorPackage
//
//  Created by BELDIN Yaroslav on 23.11.2025.
//

import Foundation

enum BannerError: Error, Sendable {
    case bannerNotFound
    case invalidImageURL
}

struct Service: BannerService, @unchecked Sendable {
    private let baseURL = URL(string: "http://api.surebet-calculator.ru")!
    private let session: URLSession
    private let defaults: UserDefaults

    init(
        session: URLSession = .shared,
        defaults: UserDefaults = .standard
    ) {
        self.session = session
        self.defaults = defaults
    }

    func fetchBannerAndImage() async throws {
        print("[Service] Запрос баннера и картинки начат")

        do {
            let banner = try await fetchBanner()

            guard !banner.imageURL.absoluteString.isEmpty else {
                print("[Service] Баннер содержит пустой imageURL — очищаем кэш")
                clearAllBannerData()
                throw BannerError.invalidImageURL
            }

            let storedImageURL = getStoredBannerImageURL()
            print("[Service] Текущий URL сохранённой картинки: \(storedImageURL?.absoluteString ?? "nil")")
            print("[Service] URL картинки из баннера: \(banner.imageURL.absoluteString)")

            if storedImageURL != banner.imageURL || getStoredBannerImageData() == nil {
                print("[Service] URL изменился, отсутствует или нет данных — скачиваем новую картинку…")
                try await downloadImage(from: banner.imageURL)
            } else {
                print("[Service] URL совпадает и данные есть — скачивание картинки не требуется")
            }

            print("[Service] Запрос баннера и картинки завершён")
        } catch {
            print("[Service] Ошибка загрузки: \(error). Очищаем кэш баннера и картинки")
            clearAllBannerData()
            throw error
        }
    }

    func fetchBanner() async throws -> BannerModel {
        let url = baseURL.appendingPathComponent("banner")
        print("[Service] Отправляем GET \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10

        let (data, response) = try await session.data(for: request)
        print("[Service] Получен ответ на баннер")

        guard let httpResponse = response as? HTTPURLResponse else {
            print("[Service] Ошибка: ответ не HTTPURLResponse")
            throw URLError(.badServerResponse)
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            print("[Service] Ошибка: код \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }

        guard !data.isEmpty else {
            print("[Service] Ответ пустой — баннер отсутствует. Очищаем кэш")
            clearAllBannerData()
            throw BannerError.bannerNotFound
        }

        let decoder = JSONDecoder()
        let banner = try decoder.decode(BannerModel.self, from: data)

        print("[Service] Баннер успешно декодирован: \(banner)")
        saveBannerToDefaults(banner)

        return banner
    }

    func saveBannerToDefaults(_ banner: BannerModel) {
        print("[Service] Сохранение баннера в UserDefaults…")
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(banner) {
            defaults.set(data, forKey: UserDefaultsKeys.banner)
            print("[Service] Баннер сохранён")
        } else {
            print("[Service] Не удалось закодировать баннер")
        }
    }

    func getBannerFromDefaults() -> BannerModel? {
        print("[Service] Чтение баннера из UserDefaults")
        guard let data = defaults.data(forKey: UserDefaultsKeys.banner) else {
            print("[Service] Баннер не найден в UserDefaults")
            return nil
        }

        let decoder = JSONDecoder()
        let banner = try? decoder.decode(BannerModel.self, from: data)
        print("[Service] Прочитанный баннер: \(String(describing: banner))")
        return banner
    }

    func clearBannerFromDefaults() {
        print("[Service] Удаление баннера из UserDefaults")
        defaults.removeObject(forKey: UserDefaultsKeys.banner)
    }

    func downloadImage(from url: URL) async throws {
        print("[Service] Скачивание картинки: \(url.absoluteString)")
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("[Service] Ошибка: ответ не HTTPURLResponse")
            throw URLError(.badServerResponse)
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            print("[Service] Ошибка скачивания: код \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }

        guard !data.isEmpty else {
            print("[Service] Получены пустые данные изображения — очищаем кэш")
            clearAllBannerData()
            throw URLError(.cannotDecodeContentData)
        }

        saveBannerImageData(data, imageURL: url)
        print("[Service] Картинка успешно скачана и сохранена")
    }

    func saveBannerImageData(_ data: Data, imageURL: URL) {
        print("[Service] Сохранение картинки и URL в UserDefaults")
        defaults.set(data, forKey: UserDefaultsKeys.bannerImageData)
        defaults.set(imageURL.absoluteString, forKey: UserDefaultsKeys.bannerImageURLString)
    }

    func getStoredBannerImageData() -> Data? {
        print("[Service] Получение картинки из UserDefaults")
        let data = defaults.data(forKey: UserDefaultsKeys.bannerImageData)
        print("[Service] Картинка найдена: \(data != nil)")
        return data
    }

    func getStoredBannerImageURL() -> URL? {
        print("[Service] Получение URL картинки из UserDefaults")
        guard let urlString = defaults.string(forKey: UserDefaultsKeys.bannerImageURLString) else {
            print("[Service] URL картинки не найден")
            return nil
        }
        let url = URL(string: urlString)
        print("[Service] URL картинки: \(url?.absoluteString ?? "nil")")
        return url
    }

    func isBannerFullyCached() -> Bool {
        print("[Service] Проверка полного кэша баннера и картинки")
        guard getBannerFromDefaults() != nil else {
            print("[Service] Баннер отсутствует в кэше")
            return false
        }

        guard getStoredBannerImageData() != nil else {
            print("[Service] Картинка отсутствует в кэше")
            return false
        }

        print("[Service] Кэш баннера и картинки полный")
        return true
    }

    private func clearAllBannerData() {
        print("[Service] Полная очистка данных баннера и картинки из UserDefaults")
        defaults.removeObject(forKey: UserDefaultsKeys.banner)
        defaults.removeObject(forKey: UserDefaultsKeys.bannerImageData)
        defaults.removeObject(forKey: UserDefaultsKeys.bannerImageURLString)
    }
}
