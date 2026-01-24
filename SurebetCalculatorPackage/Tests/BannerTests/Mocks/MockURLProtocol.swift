import Foundation

/// Моковый URLProtocol для перехвата сетевых запросов в тестах.
/// Позволяет изолировать тесты от реальной сети, возвращая заранее подготовленные ответы.
/// Использует потокобезопасную маршрутизацию по URL для поддержки параллельных тестов.
///
/// Использование:
/// ```swift
/// let uniqueURL = URL(string: "https://test-\(UUID().uuidString).com")!
/// MockURLProtocol.register(url: uniqueURL) { request in
///     let response = HTTPURLResponse(url: request.url!, statusCode: 200, ...)!
///     return (response, testData)
/// }
/// defer { MockURLProtocol.unregister(url: uniqueURL) }
/// let config = URLSessionConfiguration.ephemeral
/// config.protocolClasses = [MockURLProtocol.self]
/// let session = URLSession(configuration: config)
/// ```
final class MockURLProtocol: URLProtocol {
    // MARK: - Type Aliases

    /// Тип обработчика запросов
    typealias RequestHandler = (URLRequest) throws -> (HTTPURLResponse, Data)

    // MARK: - Static Properties

    /// Потокобезопасный реестр хендлеров по URL.
    /// Ключ - абсолютная строка URL, значение - обработчик запросов.
    private nonisolated(unsafe) static var handlers: [String: RequestHandler] = [:]

    /// Блокировка для синхронизации доступа к реестру хендлеров
    private static let lock = NSLock()

    // MARK: - Static Methods

    /// Регистрирует обработчик для указанного URL.
    /// - Parameters:
    ///   - url: URL для регистрации обработчика
    ///   - handler: Обработчик запросов для данного URL
    static func register(url: URL, handler: @escaping RequestHandler) {
        lock.lock()
        defer { lock.unlock() }
        handlers[url.absoluteString] = handler
    }

    /// Удаляет обработчик для указанного URL.
    /// - Parameter url: URL для удаления обработчика
    static func unregister(url: URL) {
        lock.lock()
        defer { lock.unlock() }
        handlers.removeValue(forKey: url.absoluteString)
    }

    /// Получает обработчик для указанного URL.
    /// - Parameter url: URL для получения обработчика
    /// - Returns: Обработчик запросов или nil, если не найден
    private static func handler(for url: URL) -> RequestHandler? {
        lock.lock()
        defer { lock.unlock() }
        return handlers[url.absoluteString]
    }

    // MARK: - URLProtocol

    override static func canInit(with request: URLRequest) -> Bool {
        // Перехватываем все запросы, чтобы гарантировать изоляцию от реальной сети
        // Handler проверяется в startLoading()
        return true
    }

    override static func canInit(with task: URLSessionTask) -> Bool {
        // Перехватываем все задачи, чтобы гарантировать изоляцию от реальной сети
        return true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let requestURL = request.url else {
            let error = URLError(.badURL)
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        guard let handler = MockURLProtocol.handler(for: requestURL) else {
            // Если handler не установлен для данного URL, это означает,
            // что тест не настроил мок правильно
            // В этом случае выбрасываем ошибку, чтобы тест упал с понятным сообщением
            let error = URLError(.badServerResponse)
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // Ничего не делаем - тесты не требуют отмены запросов
    }
}
