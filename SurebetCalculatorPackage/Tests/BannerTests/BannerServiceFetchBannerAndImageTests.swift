import Foundation
import Testing
@testable import Banner

/// Тесты для метода fetchBannerAndImage в BannerService
struct BannerServiceFetchBannerAndImageTests {
    // MARK: - Helper Methods

    /// Создает моковый URLSession с MockURLProtocol.
    /// Гарантирует, что все сетевые запросы перехватываются моком и не уходят в реальную сеть.
    /// - Returns: Настроенный URLSession
    private func createMockURLSession() -> URLSession {
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

    // MARK: - fetchBannerAndImage() Tests

    /// Тест успешной загрузки баннера и изображения
    @Test
    func fetchBannerAndImageWhenRequestSucceeds() async throws {
        // Given
        let uniqueBaseURL = URL(string: "https://test-\(UUID().uuidString).com")!
        defer { MockURLProtocol.unregister(url: uniqueBaseURL) }

        let testBanner = createTestBanner()
        let encoder = JSONEncoder()
        let imageData = Data("test image data".utf8)

        // Создаем уникальный URL для изображения
        let uniqueImageURL = URL(string: "https://test-\(UUID().uuidString).com/image.png")!
        defer { MockURLProtocol.unregister(url: uniqueImageURL) }

        // Создаем баннер с уникальным URL изображения
        let bannerWithUniqueImage = BannerModel(
            id: testBanner.id,
            title: testBanner.title,
            body: testBanner.body,
            partnerCode: testBanner.partnerCode,
            imageURL: uniqueImageURL,
            actionURL: testBanner.actionURL
        )
        let bannerDataWithUniqueImage = try encoder.encode(bannerWithUniqueImage)

        // Регистрируем хендлер для баннера
        let bannerURL = uniqueBaseURL.appendingPathComponent("banner")
        MockURLProtocol.register(url: bannerURL) { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, bannerDataWithUniqueImage)
        }
        defer { MockURLProtocol.unregister(url: bannerURL) }

        // Регистрируем хендлер для изображения
        MockURLProtocol.register(url: uniqueImageURL) { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, imageData)
        }

        let session = createMockURLSession()
        let defaults = createTestUserDefaults()
        let service = Service(baseURL: uniqueBaseURL, session: session, defaults: defaults)

        // When
        try await service.fetchBannerAndImage()

        // Then
        #expect(service.getBannerFromDefaults() != nil)
        #expect(service.getStoredBannerImageData() != nil)
    }

    /// Тест загрузки баннера и изображения когда изображение уже закэшировано
    @Test
    func fetchBannerAndImageWhenImageAlreadyCached() async throws {
        // Given
        let uniqueBaseURL = URL(string: "https://test-\(UUID().uuidString).com")!
        defer { MockURLProtocol.unregister(url: uniqueBaseURL) }

        let testBanner = createTestBanner()
        let encoder = JSONEncoder()
        let bannerData = try encoder.encode(testBanner)
        let imageData = Data("test image data".utf8)

        // Регистрируем хендлер для баннера
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

        let session = createMockURLSession()
        let defaults = createTestUserDefaults()
        let service = Service(baseURL: uniqueBaseURL, session: session, defaults: defaults)
        defaults.set(imageData, forKey: "stored_banner_image_data")
        defaults.set(testBanner.imageURL.absoluteString, forKey: "stored_banner_image_url_string")

        // When
        try await service.fetchBannerAndImage()

        // Then
        #expect(service.getBannerFromDefaults() != nil)
        #expect(service.getStoredBannerImageData() != nil)
    }

    /// Тест обработки ошибки при загрузке баннера и изображения
    @Test
    func fetchBannerAndImageWhenNetworkError() async {
        // Given
        let uniqueBaseURL = URL(string: "https://test-\(UUID().uuidString).com")!
        defer { MockURLProtocol.unregister(url: uniqueBaseURL) }

        let bannerURL = uniqueBaseURL.appendingPathComponent("banner")
        MockURLProtocol.register(url: bannerURL) { _ in
            throw URLError(.notConnectedToInternet)
        }
        defer { MockURLProtocol.unregister(url: bannerURL) }

        let session = createMockURLSession()
        let defaults = createTestUserDefaults()
        let service = Service(baseURL: uniqueBaseURL, session: session, defaults: defaults)

        // When & Then
        // Ошибка сети может быть URLError или BannerError в зависимости от того, где она происходит
        await #expect(throws: Error.self) {
            try await service.fetchBannerAndImage()
        }

        // Кэш должен быть очищен при ошибке
        #expect(service.getBannerFromDefaults() == nil)
        #expect(service.getStoredBannerImageData() == nil)
    }

    /// Тест обработки пустого imageURL в баннере
    @Test
    func fetchBannerAndImageWhenImageURLIsEmpty() async {
        // Given
        let uniqueBaseURL = URL(string: "https://test-\(UUID().uuidString).com")!
        defer { MockURLProtocol.unregister(url: uniqueBaseURL) }

        // Создаем баннер с пустым imageURL через валидный JSON с null
        let invalidBannerJSON = Data("""
        {
            "id": "test-id",
            "title": "Test Title",
            "body": "Test Body",
            "partnerCode": "test-partner",
            "imageURL": null,
            "actionURL": "https://example.com/action"
        }
        """.utf8)

        let bannerURL = uniqueBaseURL.appendingPathComponent("banner")
        MockURLProtocol.register(url: bannerURL) { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, invalidBannerJSON)
        }
        defer { MockURLProtocol.unregister(url: bannerURL) }

        let session = createMockURLSession()
        let defaults = createTestUserDefaults()
        let service = Service(baseURL: uniqueBaseURL, session: session, defaults: defaults)

        // When & Then
        // Пустой imageURL должен выбрасывать BannerError.invalidImageURL на строке 48 Service.swift
        // Но если JSON не валиден, может быть DecodingError
        await #expect(throws: Error.self) {
            try await service.fetchBannerAndImage()
        }
    }
}
