import Foundation

@MainActor
public protocol URLOpener: Sendable {
    func open(_ url: URL)
    func open(_ urlString: String)
}
