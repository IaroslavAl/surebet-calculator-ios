import UIKit

final class PassthroughWindow: UIWindow {
    weak var interactiveView: UIView?

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let interactiveView, interactiveView.isUserInteractionEnabled else { return false }
        let pointInView = interactiveView.convert(point, from: self)
        return interactiveView.point(inside: pointInView, with: event)
    }
}
