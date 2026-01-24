import Foundation
import Testing
@testable import Banner

// swiftlint:disable file_length
/// Тесты для BannerService
struct BannerServiceTests {
    // MARK: - Helper Methods

    /// Создает моковый URLSession с MockURLProtocol.
    /// Гарантирует, что все сетевые запросы перехватываются моком и не уходят в реальную сеть.
    /// - Parameters:
    ///   - baseURL: Базовый URL для регистрации хендлера
    ///   - handler: Обработчик запросов
    /// - Returns: Настроенный URLSession
    private func createMockURLSession(
        baseURL: URL,
        handler: @escaping (URLRequest) throws -> (HTTPURLResponse, Data)
    ) -> URLSession {
        // Регистрируем handler для данного URL
        MockURLProtocol.register(url: baseURL, handler: handler)

        // Создаем новую конфигурацию для каждого теста, чтобы избежать кэширования протоколов
        let config = URLSessionConfiguration.ephemeral
        // Устанавливаем protocolClasses ПЕРЕД созданием URLSession
        // Это гарантирует, что все запросы проходят через MockURLProtocol
        config.protocolClasses = [MockURLProtocol.self]

        // Отключаем кэширование для тестов
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData

        let session = URLSession(configuration: config)
        return session
    }

    /// Создает тестовый UserDefaults с уникальным suite name
    private func createTestUserDefaults() -> UserDefaults {
        let suiteName = "test.\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName) ?? UserDefaults.standard
    }

    /// Создает тестовый BannerModel
    private func createTestBanner() -> BannerModel {
        BannerModel(
            id: "test-id",
            title: "Test Title",
            body: "Test Body",
            partnerCode: "test-partner",
            imageURL: URL(string: "https://example.com/image.png")!,
            actionURL: URL(string: "https://example.com/action")!
        )
    }

    // MARK: - fetchBanner() Tests

    /// Тест успешной загрузки баннера
    @Test
    func fetchBannerWhenRequestSucceeds() async throws {
        // Given
        let uniqueBaseURL = URL(string: "https://test-\(UUID().uuidString).com")!
        defer { MockURLProtocol.unregister(url: uniqueBaseURL) }

        let testBanner = createTestBanner()
        let encoder = JSONEncoder()
        let bannerData = try encoder.encode(testBanner)

        // Регистрируем хендлер для полного URL с путем "/banner"
        let bannerURL = uniqueBaseURL.appendingPathComponent("banner")
        MockURLProtocol.register(url: bannerURL) { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, bannerData)
        }
        defer { MockURLProtocol.unregister(url: bannerURL) }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: config)

        let defaults = createTestUserDefaults()
        let service = Service(baseURL: uniqueBaseURL, session: session, defaults: defaults)

        // When
        let banner = try await service.fetchBanner()

        // Then
        #expect(banner.id == testBanner.id)
        #expect(banner.title == testBanner.title)
        #expect(banner.body == testBanner.body)
        #expect(banner.imageURL == testBanner.imageURL)
    }

    /// Тест обработки ошибки сети
    @Test
    func fetchBannerWhenNetworkError() async {
        // Given
        let uniqueBaseURL = URL(string: "https://test-\(UUID().uuidString).com")!
        defer { MockURLProtocol.unregister(url: uniqueBaseURL) }

        let bannerURL = uniqueBaseURL.appendingPathComponent("banner")
        MockURLProtocol.register(url: bannerURL) { _ in
            throw URLError(.notConnectedToInternet)
        }
        defer { MockURLProtocol.unregister(url: bannerURL) }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: config)

        let defaults = createTestUserDefaults()
        let service = Service(baseURL: uniqueBaseURL, session: session, defaults: defaults)

        // When & Then
        // URLError должен пройти через, но если данные пустые, будет BannerError.bannerNotFound
        await #expect(throws: Error.self) {
            try await service.fetchBanner()
        }
    }

    /// Тест обработки HTTP ошибки (не 200-299)
    @Test
    func fetchBannerWhenHTTPError() async {
        // Given
        let uniqueBaseURL = URL(string: "https://test-\(UUID().uuidString).com")!
        defer { MockURLProtocol.unregister(url: uniqueBaseURL) }

        let bannerURL = uniqueBaseURL.appendingPathComponent("banner")
        MockURLProtocol.register(url: bannerURL) { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        defer { MockURLProtocol.unregister(url: bannerURL) }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: config)

        let defaults = createTestUserDefaults()
        let service = Service(baseURL: uniqueBaseURL, session: session, defaults: defaults)

        // When & Then
        // HTTP ошибка должна выбрасывать URLError(.badServerResponse) на строке 94 Service.swift
        // Но если данные пустые, может быть выбрашено BannerError.bannerNotFound
        await #expect(throws: Error.self) {
            try await service.fetchBanner()
        }
    }

    /// Тест обработки пустого ответа
    @Test
    func fetchBannerWhenEmptyResponse() async {
        // Given
        let uniqueBaseURL = URL(string: "https://test-\(UUID().uuidString).com")!
        defer { MockURLProtocol.unregister(url: uniqueBaseURL) }

        let bannerURL = uniqueBaseURL.appendingPathComponent("banner")
        MockURLProtocol.register(url: bannerURL) { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        defer { MockURLProtocol.unregister(url: bannerURL) }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: config)

        let defaults = createTestUserDefaults()
        let service = Service(baseURL: uniqueBaseURL, session: session, defaults: defaults)

        // When & Then
        // Пустые данные должны выбрасывать BannerError.bannerNotFound на строке 100 Service.swift
        // Но если происходит ошибка декодирования раньше, может быть DecodingError
        await #expect(throws: Error.self) {
            try await service.fetchBanner()
        }
    }

    /// Тест обработки невалидного JSON
    @Test
    func fetchBannerWhenInvalidJSON() async {
        // Given
        let uniqueBaseURL = URL(string: "https://test-\(UUID().uuidString).com")!
        defer { MockURLProtocol.unregister(url: uniqueBaseURL) }

        let bannerURL = uniqueBaseURL.appendingPathComponent("banner")
        MockURLProtocol.register(url: bannerURL) { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data("invalid json".utf8))
        }
        defer { MockURLProtocol.unregister(url: bannerURL) }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: config)

        let defaults = createTestUserDefaults()
        let service = Service(baseURL: uniqueBaseURL, session: session, defaults: defaults)

        // When & Then
        await #expect(throws: Error.self) {
            try await service.fetchBanner()
        }
    }

    // MARK: - saveBannerToDefaults() Tests

    /// Тест сохранения баннера в UserDefaults
    @Test
    func saveBannerToDefaultsWhenBannerProvided() {
        // Given
        let testBanner = createTestBanner()
        let defaults = createTestUserDefaults()
        let service = Service(session: .shared, defaults: defaults)

        // When
        service.saveBannerToDefaults(testBanner)

        // Then
        let savedBanner = service.getBannerFromDefaults()
        #expect(savedBanner != nil)
        #expect(savedBanner?.id == testBanner.id)
        #expect(savedBanner?.title == testBanner.title)
    }

    // MARK: - getBannerFromDefaults() Tests

    /// Тест получения баннера из UserDefaults когда он существует
    @Test
    func getBannerFromDefaultsWhenBannerExists() {
        // Given
        let testBanner = createTestBanner()
        let defaults = createTestUserDefaults()
        let service = Service(session: .shared, defaults: defaults)
        service.saveBannerToDefaults(testBanner)

        // When
        let banner = service.getBannerFromDefaults()

        // Then
        #expect(banner != nil)
        #expect(banner?.id == testBanner.id)
    }

    /// Тест получения баннера из UserDefaults когда его нет
    @Test
    func getBannerFromDefaultsWhenBannerDoesNotExist() {
        // Given
        let defaults = createTestUserDefaults()
        let service = Service(session: .shared, defaults: defaults)

        // When
        let banner = service.getBannerFromDefaults()

        // Then
        #expect(banner == nil)
    }

    // MARK: - clearBannerFromDefaults() Tests

    /// Тест очистки баннера из UserDefaults
    @Test
    func clearBannerFromDefaultsWhenBannerExists() {
        // Given
        let testBanner = createTestBanner()
        let defaults = createTestUserDefaults()
        let service = Service(session: .shared, defaults: defaults)
        service.saveBannerToDefaults(testBanner)
        #expect(service.getBannerFromDefaults() != nil)

        // When
        service.clearBannerFromDefaults()

        // Then
        #expect(service.getBannerFromDefaults() == nil)
    }

    // MARK: - downloadImage(from:) Tests

    /// Тест успешной загрузки изображения
    @Test
    func downloadImageWhenRequestSucceeds() async throws {
        // Given
        let uniqueURL = URL(string: "https://test-\(UUID().uuidString).com")!
        defer { MockURLProtocol.unregister(url: uniqueURL) }

        let imageURL = uniqueURL.appendingPathComponent("image.png")
        let imageData = Data("test image data".utf8)

        MockURLProtocol.register(url: imageURL) { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, imageData)
        }
        defer { MockURLProtocol.unregister(url: imageURL) }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: config)

        let defaults = createTestUserDefaults()
        let service = Service(session: session, defaults: defaults)

        // When
        try await service.downloadImage(from: imageURL)

        // Then
        let storedData = service.getStoredBannerImageData()
        #expect(storedData != nil)
        #expect(storedData == imageData)
        #expect(service.getStoredBannerImageURL() == imageURL)
    }

    /// Тест обработки ошибки при загрузке изображения
    @Test
    func downloadImageWhenNetworkError() async {
        // Given
        let uniqueURL = URL(string: "https://test-\(UUID().uuidString).com")!
        defer { MockURLProtocol.unregister(url: uniqueURL) }

        let imageURL = uniqueURL.appendingPathComponent("image.png")

        MockURLProtocol.register(url: imageURL) { _ in
            throw URLError(.notConnectedToInternet)
        }
        defer { MockURLProtocol.unregister(url: imageURL) }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: config)

        let defaults = createTestUserDefaults()
        let service = Service(session: session, defaults: defaults)

        // When & Then
        // Ошибка сети должна пройти через
        await #expect(throws: Error.self) {
            try await service.downloadImage(from: imageURL)
        }
    }

    /// Тест обработки пустых данных изображения
    @Test
    func downloadImageWhenEmptyData() async {
        // Given
        let uniqueURL = URL(string: "https://test-\(UUID().uuidString).com")!
        defer { MockURLProtocol.unregister(url: uniqueURL) }

        let imageURL = uniqueURL.appendingPathComponent("image.png")

        MockURLProtocol.register(url: imageURL) { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        defer { MockURLProtocol.unregister(url: imageURL) }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: config)

        let defaults = createTestUserDefaults()
        let service = Service(session: session, defaults: defaults)

        // When & Then
        // Пустые данные должны выбрасывать URLError(.cannotDecodeContentData) на строке 158 Service.swift
        await #expect(throws: Error.self) {
            try await service.downloadImage(from: imageURL)
        }
    }

    // MARK: - getStoredBannerImageData() Tests

    /// Тест получения данных изображения когда они существуют
    @Test
    func getStoredBannerImageDataWhenDataExists() {
        // Given
        let imageData = Data("test image data".utf8)
        let defaults = createTestUserDefaults()
        defaults.set(imageData, forKey: "stored_banner_image_data")
        let service = Service(session: .shared, defaults: defaults)

        // When
        let data = service.getStoredBannerImageData()

        // Then
        #expect(data != nil)
        #expect(data == imageData)
    }

    /// Тест получения данных изображения когда их нет
    @Test
    func getStoredBannerImageDataWhenDataDoesNotExist() {
        // Given
        let defaults = createTestUserDefaults()
        let service = Service(session: .shared, defaults: defaults)

        // When
        let data = service.getStoredBannerImageData()

        // Then
        #expect(data == nil)
    }

    // MARK: - getStoredBannerImageURL() Tests

    /// Тест получения URL изображения когда он существует
    @Test
    func getStoredBannerImageURLWhenURLExists() {
        // Given
        let imageURL = URL(string: "https://example.com/image.png")!
        let defaults = createTestUserDefaults()
        defaults.set(imageURL.absoluteString, forKey: "stored_banner_image_url_string")
        let service = Service(session: .shared, defaults: defaults)

        // When
        let url = service.getStoredBannerImageURL()

        // Then
        #expect(url != nil)
        #expect(url == imageURL)
    }

    /// Тест получения URL изображения когда его нет
    @Test
    func getStoredBannerImageURLWhenURLDoesNotExist() {
        // Given
        let defaults = createTestUserDefaults()
        let service = Service(session: .shared, defaults: defaults)

        // When
        let url = service.getStoredBannerImageURL()

        // Then
        #expect(url == nil)
    }

    // MARK: - isBannerFullyCached() Tests

    /// Тест проверки полного кэша когда баннер и изображение закэшированы
    @Test
    func isBannerFullyCachedWhenBannerAndImageCached() {
        // Given
        let testBanner = createTestBanner()
        let imageData = Data("test image data".utf8)
        let defaults = createTestUserDefaults()
        let service = Service(session: .shared, defaults: defaults)
        service.saveBannerToDefaults(testBanner)
        defaults.set(imageData, forKey: "stored_banner_image_data")
        defaults.set(testBanner.imageURL.absoluteString, forKey: "stored_banner_image_url_string")

        // When
        let isCached = service.isBannerFullyCached()

        // Then
        #expect(isCached == true)
    }

    /// Тест проверки полного кэша когда баннер не закэширован
    @Test
    func isBannerFullyCachedWhenBannerNotCached() {
        // Given
        let imageData = Data("test image data".utf8)
        let defaults = createTestUserDefaults()
        let service = Service(session: .shared, defaults: defaults)
        defaults.set(imageData, forKey: "stored_banner_image_data")

        // When
        let isCached = service.isBannerFullyCached()

        // Then
        #expect(isCached == false)
    }

    /// Тест проверки полного кэша когда изображение не закэшировано
    @Test
    func isBannerFullyCachedWhenImageNotCached() {
        // Given
        let testBanner = createTestBanner()
        let defaults = createTestUserDefaults()
        let service = Service(session: .shared, defaults: defaults)
        service.saveBannerToDefaults(testBanner)

        // When
        let isCached = service.isBannerFullyCached()

        // Then
        #expect(isCached == false)
    }

}
