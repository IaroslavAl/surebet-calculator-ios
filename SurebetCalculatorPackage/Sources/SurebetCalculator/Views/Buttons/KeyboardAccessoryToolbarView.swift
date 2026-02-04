import UIKit

final class KeyboardAccessoryToolbarView: UIView {
    private enum Layout {
        static let buttonSize: CGFloat = 44
        static let sidePadding: CGFloat = 20
        static let verticalPadding: CGFloat = 12
        static let borderWidth: CGFloat = 1
        static let hitSlop: CGFloat = 8
    }

    private let clearButton = UIButton(type: .system)
    private let doneButton = UIButton(type: .system)
    private var clearAction: (() -> Void)?
    private var doneAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupButtons()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: Layout.buttonSize + Layout.verticalPadding * 2
        )
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard isUserInteractionEnabled, !isHidden, alpha > 0.01 else { return false }
        let clearFrame = clearButton.frame.insetBy(dx: -Layout.hitSlop, dy: -Layout.hitSlop)
        let doneFrame = doneButton.frame.insetBy(dx: -Layout.hitSlop, dy: -Layout.hitSlop)
        return clearFrame.contains(point) || doneFrame.contains(point)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyStyle()
    }

    func configure(onClear: @escaping () -> Void, onDone: @escaping () -> Void) {
        clearAction = onClear
        doneAction = onDone
        applyStyle()
    }

    func updateActions(onClear: @escaping () -> Void, onDone: @escaping () -> Void) {
        clearAction = onClear
        doneAction = onDone
    }

    @objc private func handleClearTap() {
        clearAction?()
    }

    @objc private func handleDoneTap() {
        doneAction?()
    }

    private func setupButtons() {
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        clearButton.addTarget(self, action: #selector(handleClearTap), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(handleDoneTap), for: .touchUpInside)

        clearButton.setImage(UIImage(systemName: "trash"), for: .normal)
        doneButton.setImage(UIImage(systemName: "xmark"), for: .normal)

        clearButton.accessibilityIdentifier = AccessibilityIdentifiers.Keyboard.clearButton
        doneButton.accessibilityIdentifier = AccessibilityIdentifiers.Keyboard.doneButton

        addSubview(clearButton)
        addSubview(doneButton)
        applyStyle()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            clearButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.sidePadding),
            clearButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: Layout.buttonSize),
            clearButton.heightAnchor.constraint(equalToConstant: Layout.buttonSize),

            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.sidePadding),
            doneButton.centerYAnchor.constraint(equalTo: clearButton.centerYAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: Layout.buttonSize),
            doneButton.heightAnchor.constraint(equalToConstant: Layout.buttonSize)
        ])
    }

    private func applyStyle() {
        let backgroundColor = UIColor.secondarySystemBackground
        let borderColor = UIColor.separator.withAlphaComponent(0.8).cgColor
        let tintColor = UIColor.label

        clearButton.backgroundColor = backgroundColor
        clearButton.tintColor = tintColor
        clearButton.layer.cornerRadius = Layout.buttonSize / 2
        clearButton.layer.borderWidth = Layout.borderWidth
        clearButton.layer.borderColor = borderColor

        doneButton.backgroundColor = backgroundColor
        doneButton.tintColor = tintColor
        doneButton.layer.cornerRadius = Layout.buttonSize / 2
        doneButton.layer.borderWidth = Layout.borderWidth
        doneButton.layer.borderColor = borderColor
    }
}
