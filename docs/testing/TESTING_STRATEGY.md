# Testing Strategy

## Swift Testing Framework

| XCTest | Swift Testing |
|---|---|
| `import XCTest` | `import Testing` |
| `class: XCTestCase` | `struct` |
| `func testSomething()` | `@Test func something()` |
| `XCTAssertEqual` | `#expect(a == b)` |
| `XCTFail()` | `Issue.record()` |

## Базовые правила
- Используем Swift Testing, не XCTest.
- Если SUT `@MainActor`, тестовая структура тоже `@MainActor`.
- Shared state (UserDefaults) — `@Suite(.serialized)`.
- В unit/integration/UI тестах запрещены `Thread.sleep`/`Task.sleep`.
- В UI‑тестах ждать только через `waitForExistence(timeout:)` или `XCTWaiter`.
- MockURLProtocol: потокобезопасный реестр по полному URL, без глобального handler.

## Mock Pattern (минимум)
```swift
final class MockService: ServiceProtocol, @unchecked Sendable {
    var methodCallCount = 0
    var lastParameter: String?
    var resultToReturn: Result?

    func method(param: String) -> Result? {
        methodCallCount += 1
        lastParameter = param
        return resultToReturn
    }
}
```

## MockURLProtocol (шаблон)
```swift
final class MockURLProtocol: URLProtocol {
    static func register(url: URL, handler: @escaping (URLRequest) throws -> (HTTPURLResponse, Data))
    static func unregister(url: URL)
}

@Test
func fetchBanner() async throws {
    let url = URL(string: "https://test.com/banner")!
    MockURLProtocol.register(url: url) { request in
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, bannerData)
    }
    defer { MockURLProtocol.unregister(url: url) }

    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let session = URLSession(configuration: config)

    let service = Service(session: session)
    let banner = try await service.fetchBanner()
    #expect(banner.id == "expected")
}
```

## Шаблон теста
```swift
import Testing
@testable import ModuleName

@MainActor
struct FeatureTests {
    private func createViewModel() -> FeatureViewModel { FeatureViewModel() }

    @Test
    func featureWorks() {
        let viewModel = createViewModel()
        viewModel.performAction()
        #expect(viewModel.state == .expected)
    }
}
```
