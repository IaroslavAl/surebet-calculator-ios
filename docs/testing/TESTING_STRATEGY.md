# Testing Strategy

## Swift Testing Framework

| XCTest | Swift Testing |
|--------|---------------|
| `import XCTest` | `import Testing` |
| `class: XCTestCase` | `struct` |
| `func testSomething()` | `@Test func something()` |
| `XCTAssertEqual` | `#expect(a == b)` |
| `XCTFail()` | `Issue.record()` |

---

## Test Structure

```
Tests/
├── ModuleNameTests/
│   ├── ModuleNameViewModelTests.swift
│   ├── ServiceTests.swift
│   └── Mocks/
│       └── MockService.swift
└── surebet-calculator.xctestplan
```

---

## Given-When-Then

```swift
@Test
func handleReviewYes() async {
    // Given
    let mockAnalytics = MockAnalyticsService()
    let viewModel = createViewModel(analyticsService: mockAnalytics)
    
    // When
    await viewModel.handleReviewYes()
    
    // Then
    #expect(mockAnalytics.logCallCount == 1)
    #expect(mockAnalytics.lastEventName == "RequestReview")
}
```

---

## MainActor Isolation

**Правило:** `@MainActor` на тестовой структуре если ViewModel тоже `@MainActor`.

```swift
@MainActor
struct SurebetCalculatorViewModelTests {
    @Test
    func selectRow() {
        let viewModel = SurebetCalculatorViewModel()
        viewModel.send(.selectRow(.row(0)))
        #expect(viewModel.selectedRow == .row(0))
    }
}
```

**Async тесты:**
```swift
@Test
func asyncMethod() async {
    await MainActor.run {
        // код на MainActor
    }
}
```

---

## @Suite(.serialized)

Для тестов с shared state (UserDefaults):

```swift
@MainActor
@Suite(.serialized)
struct RootViewModelTests {
    func clearTestUserDefaults() {
        UserDefaults.standard.removeObject(forKey: "onboardingIsShown")
    }
    
    @Test
    func shouldShowOnboarding() {
        clearTestUserDefaults()
        let viewModel = createViewModel()
        #expect(viewModel.shouldShowOnboarding == true)
    }
}
```

---

## Mock Pattern

```swift
final class MockService: ServiceProtocol, @unchecked Sendable {
    // Tracking
    var methodCallCount = 0
    var lastParameter: String?
    var methodCalls: [(param: String, date: Date)] = []
    
    // Configurable result
    var resultToReturn: Result?
    
    // Protocol implementation
    func method(param: String) -> Result? {
        methodCallCount += 1
        lastParameter = param
        methodCalls.append((param, Date()))
        return resultToReturn
    }
}
```

**Правила:**
- `@unchecked Sendable` для Swift 6
- `*CallCount` — счётчик вызовов
- `last*` — последние параметры
- `*Result` — configurable return value

---

## Network Mocks (MockURLProtocol)

```swift
final class MockURLProtocol: URLProtocol {
    static func register(url: URL, handler: @escaping (URLRequest) throws -> (HTTPURLResponse, Data))
    static func unregister(url: URL)
}

// Usage
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

---

## Helper Methods

```swift
// Factory для ViewModel с моками
func createViewModel(
    analyticsService: AnalyticsService? = nil,
    reviewService: ReviewService? = nil
) -> RootViewModel {
    RootViewModel(
        analyticsService: analyticsService ?? MockAnalyticsService(),
        reviewService: reviewService ?? MockReviewService()
    )
}

// Очистка UserDefaults
func clearTestUserDefaults() {
    let keys = ["onboardingIsShown", "numberOfOpenings", "1.7.0"]
    keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
}
```

---

## Test File Template

```swift
import Testing
@testable import ModuleName

@MainActor
struct FeatureTests {
    // MARK: - Helpers
    
    private func createViewModel() -> FeatureViewModel {
        FeatureViewModel()
    }
    
    // MARK: - Tests
    
    @Test
    func featureWorks() {
        // Given
        let viewModel = createViewModel()
        
        // When
        viewModel.performAction()
        
        // Then
        #expect(viewModel.state == .expected)
    }
    
    @Test
    func asyncFeatureWorks() async {
        // Given
        let viewModel = createViewModel()
        
        // When
        await viewModel.performAsyncAction()
        
        // Then
        #expect(viewModel.state == .expected)
    }
}
```

---

## Checklist

- [ ] `import Testing`, не XCTest
- [ ] `struct`, не class
- [ ] `@Test`, не func test...()
- [ ] `#expect()`, не XCTAssert
- [ ] `@MainActor` для MainActor ViewModel
- [ ] `@Suite(.serialized)` для UserDefaults
- [ ] `@unchecked Sendable` на моках
- [ ] Given-When-Then структура
- [ ] Helper-методы для factory
