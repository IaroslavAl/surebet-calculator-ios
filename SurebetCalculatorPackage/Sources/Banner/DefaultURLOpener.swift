import UIKit

@MainActor
public struct DefaultURLOpener: URLOpener {
    public init() {}

    public func open(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    public func open(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        open(url)
    }
}
