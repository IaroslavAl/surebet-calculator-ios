import Foundation
import Testing
@testable import Banner

/// Тесты для BannerService
struct BannerServiceTests {
    // MARK: - Helper Methods

    /// Создает моковый URLSession с MockURLProtocol
    private func createMockURLSession(handler: @escaping (URLRequest) throws -> (HTTPURLResponse, Data)) -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.requestHandler = handler
        return URLSession(configuration: config)
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
        let testBanner = createTestBanner()
        let encoder = JSONEncoder()
        let bannerData = try encoder.encode(testBanner)

        let session = createMockURLSession { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, bannerData)
        }

        let defaults = createTestUserDefaults()
        let service = Service(session: session, defaults: defaults)

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
        let session = createMockURLSession { _ in
            throw URLError(.notConnectedToInternet)
        }

        let defaults = createTestUserDefaults()
        let service = Service(session: session, defaults: defaults)

        // When & Then
        await #expect(throws: URLError.self) {
            try await service.fetchBanner()
        }
    }

    /// Тест обработки HTTP ошибки (не 200-299)
    @Test
    func fetchBannerWhenHTTPError() async {
        // Given
        let session = createMockURLSession { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let defaults = createTestUserDefaults()
        let service = Service(session: session, defaults: defaults)

        // When & Then
        await #expect(throws: URLError.self) {
            try await service.fetchBanner()
        }
    }

    /// Тест обработки пустого ответа
    @Test
    func fetchBannerWhenEmptyResponse() async {
        // Given
        let session = createMockURLSession { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let defaults = createTestUserDefaults()
        let service = Service(session: session, defaults: defaults)

        // When & Then
        await #expect(throws: BannerError.self) {
            try await service.fetchBanner()
        }
    }

    /// Тест обработки невалидного JSON
    @Test
    func fetchBannerWhenInvalidJSON() async {
        // Given
        let session = createMockURLSession { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, "invalid json".data(using: .utf8)!)
        }

        let defaults = createTestUserDefaults()
        let service = Service(session: session, defaults: defaults)

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
        let imageURL = URL(string: "https://example.com/image.png")!
        let imageData = "test image data".data(using: .utf8)!

        let session = createMockURLSession { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, imageData)
        }

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
        let imageURL = URL(string: "https://example.com/image.png")!

        let session = createMockURLSession { _ in
            throw URLError(.notConnectedToInternet)
        }

        let defaults = createTestUserDefaults()
        let service = Service(session: session, defaults: defaults)

        // When & Then
        await #expect(throws: URLError.self) {
            try await service.downloadImage(from: imageURL)
        }
    }

    /// Тест обработки пустых данных изображения
    @Test
    func downloadImageWhenEmptyData() async {
        // Given
        let imageURL = URL(string: "https://example.com/image.png")!

        let session = createMockURLSession { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let defaults = createTestUserDefaults()
        let service = Service(session: session, defaults: defaults)

        // When & Then
        await #expect(throws: URLError.self) {
            try await service.downloadImage(from: imageURL)
        }
    }

    // MARK: - getStoredBannerImageData() Tests

    /// Тест получения данных изображения когда они существуют
    @Test
    func getStoredBannerImageDataWhenDataExists() {
        // Given
        let imageData = "test image data".data(using: .utf8)!
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
        let imageData = "test image data".data(using: .utf8)!
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
        let imageData = "test image data".data(using: .utf8)!
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

    // MARK: - fetchBannerAndImage() Tests

    /// Тест успешной загрузки баннера и изображения
    @Test
    func fetchBannerAndImageWhenRequestSucceeds() async throws {
        // Given
        let testBanner = createTestBanner()
        let encoder = JSONEncoder()
        let bannerData = try encoder.encode(testBanner)
        let imageData = "test image data".data(using: .utf8)!

        var requestCount = 0
        let session = createMockURLSession { request in
            requestCount += 1
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            // Первый запрос - баннер, второй - изображение
            if request.url?.path.contains("banner") == true {
                return (response, bannerData)
            } else {
                return (response, imageData)
            }
        }

        let defaults = createTestUserDefaults()
        let service = Service(session: session, defaults: defaults)

        // When
        try await service.fetchBannerAndImage()

        // Then
        #expect(requestCount == 2) // Баннер + изображение
        #expect(service.getBannerFromDefaults() != nil)
        #expect(service.getStoredBannerImageData() != nil)
    }

    /// Тест загрузки баннера и изображения когда изображение уже закэшировано
    @Test
    func fetchBannerAndImageWhenImageAlreadyCached() async throws {
        // Given
        let testBanner = createTestBanner()
        let encoder = JSONEncoder()
        let bannerData = try encoder.encode(testBanner)
        let imageData = "test image data".data(using: .utf8)!

        var requestCount = 0
        let session = createMockURLSession { request in
            requestCount += 1
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            // Только запрос баннера, изображение уже в кэше
            return (response, bannerData)
        }

        let defaults = createTestUserDefaults()
        let service = Service(session: session, defaults: defaults)
        defaults.set(imageData, forKey: "stored_banner_image_data")
        defaults.set(testBanner.imageURL.absoluteString, forKey: "stored_banner_image_url_string")

        // When
        try await service.fetchBannerAndImage()

        // Then
        #expect(requestCount == 1) // Только баннер
        #expect(service.getBannerFromDefaults() != nil)
        #expect(service.getStoredBannerImageData() != nil)
    }

    /// Тест обработки ошибки при загрузке баннера и изображения
    @Test
    func fetchBannerAndImageWhenNetworkError() async {
        // Given
        let session = createMockURLSession { _ in
            throw URLError(.notConnectedToInternet)
        }

        let defaults = createTestUserDefaults()
        let service = Service(session: session, defaults: defaults)

        // When & Then
        await #expect(throws: URLError.self) {
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
        var testBanner = createTestBanner()
        // Создаем баннер с пустым imageURL через reflection или другой способ
        // Но так как BannerModel - это struct, нам нужно создать его с пустым URL
        // Для этого создадим JSON с пустым imageURL
        let invalidBannerJSON = """
        {
            "id": "test-id",
            "title": "Test Title",
            "body": "Test Body",
            "partnerCode": "test-partner",
            "imageURL": "",
            "actionURL": "https://example.com/action"
        }
        """.data(using: .utf8)!

        let session = createMockURLSession { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, invalidBannerJSON)
        }

        let defaults = createTestUserDefaults()
        let service = Service(session: session, defaults: defaults)

        // When & Then
        await #expect(throws: BannerError.self) {
            try await service.fetchBannerAndImage()
        }
    }
}
