import UIKit

@MainActor
struct DefaultURLOpener: URLOpener {
    func open(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func open(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        open(url)
    }
}
