import UIKit

@MainActor
final class KeyboardAccessoryOverlayManager {
    private enum Layout {
        static let animationFallbackDuration: Double = 0.25
        static let animationFallbackCurve: Int = 7
    }

    private let toolbarView = KeyboardAccessoryToolbarView()
    private var observers: [NSObjectProtocol] = []
    private weak var hostWindow: UIWindow?
    private weak var containerView: UIView?
    private weak var keyboardGuideView: UIView?
    private var constraints: [NSLayoutConstraint] = []

    init() {
        toolbarView.configure(onClear: {}, onDone: {})
        toolbarView.alpha = 0
        toolbarView.isUserInteractionEnabled = false
    }

    func attach(to view: UIView) {
        guard let window = resolveHostWindow(for: view) else {
            Task { @MainActor [weak self, weak view] in
                guard let self, let view else { return }
                self.attach(to: view)
            }
            return
        }
        install(hostWindow: window)
    }

    func updateActions(onClear: @escaping () -> Void, onDone: @escaping () -> Void) {
        toolbarView.updateActions(onClear: onClear, onDone: onDone)
    }

    func teardown() {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers.removeAll()
        NSLayoutConstraint.deactivate(constraints)
        constraints.removeAll()
        toolbarView.removeFromSuperview()
        hostWindow = nil
        containerView = nil
        keyboardGuideView = nil
    }

    private func install(hostWindow: UIWindow) {
        let guideView = hostWindow.rootViewController?.view ?? hostWindow
        let containerView = hostWindow
        if self.hostWindow === hostWindow, toolbarView.superview === containerView { return }
        teardown()
        self.hostWindow = hostWindow
        self.containerView = containerView
        keyboardGuideView = guideView
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(toolbarView)

        let bottomConstraint = toolbarView.bottomAnchor.constraint(
            equalTo: guideView.keyboardLayoutGuide.topAnchor,
            constant: -AppConstants.Padding.small
        )
        constraints = [
            toolbarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            toolbarView.heightAnchor.constraint(equalToConstant: toolbarView.intrinsicContentSize.height),
            bottomConstraint
        ]
        NSLayoutConstraint.activate(constraints)
        containerView.layoutIfNeeded()

        toolbarView.alpha = 0
        toolbarView.isUserInteractionEnabled = false
        registerObservers()
    }

    private func registerObservers() {
        let willShow = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let frame = notification.userInfo?[
                UIResponder.keyboardFrameEndUserInfoKey
            ] as? CGRect else { return }
            let duration = notification.userInfo?[
                UIResponder.keyboardAnimationDurationUserInfoKey
            ] as? Double ?? Layout.animationFallbackDuration
            let curveRaw = notification.userInfo?[
                UIResponder.keyboardAnimationCurveUserInfoKey
            ] as? Int ?? Layout.animationFallbackCurve
            MainActor.assumeIsolated {
                self?.handleKeyboardVisibility(
                    frame: frame,
                    duration: duration,
                    curveRaw: curveRaw
                )
            }
        }

        let willChange = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let frame = notification.userInfo?[
                UIResponder.keyboardFrameEndUserInfoKey
            ] as? CGRect else { return }
            let duration = notification.userInfo?[
                UIResponder.keyboardAnimationDurationUserInfoKey
            ] as? Double ?? Layout.animationFallbackDuration
            let curveRaw = notification.userInfo?[
                UIResponder.keyboardAnimationCurveUserInfoKey
            ] as? Int ?? Layout.animationFallbackCurve
            MainActor.assumeIsolated {
                self?.handleKeyboardVisibility(
                    frame: frame,
                    duration: duration,
                    curveRaw: curveRaw
                )
            }
        }

        let willHide = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let frame = notification.userInfo?[
                UIResponder.keyboardFrameEndUserInfoKey
            ] as? CGRect else { return }
            let duration = notification.userInfo?[
                UIResponder.keyboardAnimationDurationUserInfoKey
            ] as? Double ?? Layout.animationFallbackDuration
            let curveRaw = notification.userInfo?[
                UIResponder.keyboardAnimationCurveUserInfoKey
            ] as? Int ?? Layout.animationFallbackCurve
            MainActor.assumeIsolated {
                self?.handleKeyboardVisibility(
                    frame: frame,
                    duration: duration,
                    curveRaw: curveRaw
                )
            }
        }

        observers = [willShow, willChange, willHide]
    }

    private func handleKeyboardVisibility(frame: CGRect, duration: Double, curveRaw: Int) {
        guard let hostWindow else { return }
        let screenBounds = hostWindow.screen.bounds
        let isVisible = frame.minY < screenBounds.maxY && frame.height > 0
        updateVisibilityFromKeyboard(
            animated: true,
            duration: duration,
            curveRaw: curveRaw,
            isVisibleOverride: isVisible
        )
    }

    private func resolveHostWindow(for view: UIView) -> UIWindow? {
        if let window = view.window { return window }
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let activeScenes = scenes.filter { $0.activationState == .foregroundActive }
        let searchScenes = activeScenes.isEmpty ? scenes : activeScenes
        for scene in searchScenes {
            if let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first {
                return window
            }
        }
        return nil
    }

    private func updateVisibilityFromKeyboard(
        animated: Bool,
        duration: Double,
        curveRaw: Int,
        isVisibleOverride: Bool? = nil
    ) {
        guard let keyboardGuideView, let containerView else { return }
        keyboardGuideView.layoutIfNeeded()
        let layoutFrame = keyboardGuideView.keyboardLayoutGuide.layoutFrame
        let isVisible = isVisibleOverride ?? (layoutFrame.height > 0)

        toolbarView.isUserInteractionEnabled = isVisible
        let curve = UIView.AnimationCurve(rawValue: curveRaw) ?? .easeOut
        let options = UIView.AnimationOptions(rawValue: UInt(curve.rawValue << 16))

        let updates = {
            if isVisible {
                self.toolbarView.alpha = 1
            }
            containerView.layoutIfNeeded()
        }

        if animated && duration > 0 {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: [options, .beginFromCurrentState],
                animations: updates
            ) { _ in
                if !isVisible {
                    self.toolbarView.alpha = 0
                }
            }
        } else {
            updates()
            if !isVisible {
                toolbarView.alpha = 0
            }
        }
    }
}
