import UIKit

@MainActor
final class KeyboardAccessoryOverlayManager {
    private enum Layout {
        static let animationFallbackDuration: Double = 0.25
        static let animationFallbackCurve: Int = 7
    }

    private let toolbarView = KeyboardAccessoryToolbarView()
    private var observers: [NSObjectProtocol] = []
    private var bottomConstraint: NSLayoutConstraint?
    private weak var hostWindow: UIWindow?
    private var lastKeyboardFrame: CGRect?
    private var lastKeyboardAnimation = (
        duration: Layout.animationFallbackDuration,
        curveRaw: Layout.animationFallbackCurve
    )
    private var overlayWindow: PassthroughWindow?
    private var containerView: UIView?

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
        bottomConstraint?.isActive = false
        bottomConstraint = nil
        containerView = nil
        lastKeyboardFrame = nil
        lastKeyboardAnimation = (
            duration: Layout.animationFallbackDuration,
            curveRaw: Layout.animationFallbackCurve
        )
        overlayWindow?.isHidden = true
        overlayWindow?.interactiveView = nil
        overlayWindow?.rootViewController = nil
        overlayWindow = nil
        hostWindow = nil
    }

    private func install(hostWindow: UIWindow) {
        if self.hostWindow === hostWindow, overlayWindow != nil { return }
        teardown()
        self.hostWindow = hostWindow
        guard let scene = hostWindow.windowScene else { return }

        let overlayWindow = PassthroughWindow(windowScene: scene)
        overlayWindow.windowLevel = .alert + 1
        overlayWindow.backgroundColor = .clear
        overlayWindow.isUserInteractionEnabled = true

        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        controller.view.isUserInteractionEnabled = true
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayWindow.rootViewController = controller
        overlayWindow.interactiveView = toolbarView

        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        controller.view.addSubview(toolbarView)

        bottomConstraint = toolbarView.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor)
        NSLayoutConstraint.activate([
            toolbarView.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
            toolbarView.heightAnchor.constraint(equalToConstant: toolbarView.intrinsicContentSize.height),
            bottomConstraint!
        ])

        overlayWindow.frame = hostWindow.frame
        controller.view.frame = overlayWindow.bounds
        overlayWindow.isHidden = false
        controller.view.layoutIfNeeded()

        self.overlayWindow = overlayWindow
        self.containerView = controller.view

        updateFromHost(animated: false)
        Task { @MainActor [weak self] in
            self?.updateFromHost(animated: false)
        }

        registerObservers()
    }

    private func registerObservers() {
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
            Task { @MainActor in
                self?.handleKeyboard(frame: frame, duration: duration, curveRaw: curveRaw)
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
            Task { @MainActor in
                self?.handleKeyboard(frame: frame, duration: duration, curveRaw: curveRaw)
            }
        }

        let didShow = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardDidShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.updateFromHost(animated: false)
            }
        }

        let didHide = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardDidHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.updateFromHost(animated: false)
            }
        }

        observers = [willChange, willHide, didShow, didHide]
    }

    private func updateFromHost(animated: Bool) {
        guard let hostWindow, let overlayWindow else { return }
        hostWindow.layoutIfNeeded()
        syncOverlayFrame(for: hostWindow)
        if let lastKeyboardFrame {
            let duration = animated ? lastKeyboardAnimation.duration : 0
            let curveRaw = lastKeyboardAnimation.curveRaw
            let frameInOverlay = overlayWindow.convert(lastKeyboardFrame, from: nil)
            let isVisible = frameInOverlay.minY < overlayWindow.bounds.maxY
            applyVisibility(
                isVisible: isVisible,
                keyboardTop: frameInOverlay.minY,
                duration: duration,
                curveRaw: curveRaw
            )
            return
        }
        let keyboardTopInHost = hostWindow.keyboardLayoutGuide.layoutFrame.minY
        let isVisible = keyboardTopInHost < hostWindow.bounds.maxY
        guard isVisible else {
            let duration = animated ? Layout.animationFallbackDuration : 0
            applyVisibility(
                isVisible: false,
                keyboardTop: overlayWindow.bounds.maxY,
                duration: duration,
                curveRaw: Layout.animationFallbackCurve
            )
            return
        }
        let keyboardTopInScreen = hostWindow.convert(CGPoint(x: 0, y: keyboardTopInHost), to: nil).y
        let keyboardTopInOverlay = overlayWindow.convert(
            CGPoint(x: 0, y: keyboardTopInScreen),
            from: nil
        ).y
        applyVisibility(
            isVisible: true,
            keyboardTop: keyboardTopInOverlay,
            duration: animated ? Layout.animationFallbackDuration : 0,
            curveRaw: Layout.animationFallbackCurve
        )
    }

    private func handleKeyboard(frame: CGRect, duration: Double, curveRaw: Int) {
        lastKeyboardFrame = frame
        lastKeyboardAnimation = (duration: duration, curveRaw: curveRaw)
        guard let overlayWindow, let hostWindow else { return }
        syncOverlayFrame(for: hostWindow)
        let frameInOverlay = overlayWindow.convert(frame, from: nil)
        let isVisible = frameInOverlay.minY < overlayWindow.bounds.maxY
        applyVisibility(
            isVisible: isVisible,
            keyboardTop: frameInOverlay.minY,
            duration: duration,
            curveRaw: curveRaw
        )
    }

    private func applyVisibility(isVisible: Bool, keyboardTop: CGFloat, duration: Double, curveRaw: Int) {
        guard let overlayWindow, let containerView, let bottomConstraint else { return }
        let keyboardHeight = max(0, overlayWindow.bounds.maxY - keyboardTop)
        let targetConstant = isVisible ? -(keyboardHeight + AppConstants.Padding.small) : 0
        bottomConstraint.constant = targetConstant
        toolbarView.isUserInteractionEnabled = isVisible

        let curve = UIView.AnimationCurve(rawValue: curveRaw) ?? .easeOut
        let options = UIView.AnimationOptions(rawValue: UInt(curve.rawValue << 16))

        let updates = {
            containerView.layoutIfNeeded()
            self.toolbarView.alpha = isVisible ? 1 : 0
        }

        if duration > 0 {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: [options, .beginFromCurrentState],
                animations: updates
            )
        } else {
            updates()
        }
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

    private func syncOverlayFrame(for hostWindow: UIWindow) {
        guard let overlayWindow else { return }
        let targetFrame = hostWindow.frame
        if overlayWindow.frame != targetFrame {
            overlayWindow.frame = targetFrame
        }
    }
}
