import UIKit

final class KeyboardAccessoryToolbarView: UIView {
    private enum Layout {
        static let buttonSizePhone: CGFloat = 36
        static let buttonSizePad: CGFloat = 44
        static let sidePadding: CGFloat = 16
        static let verticalPadding: CGFloat = 0
        static let borderWidth: CGFloat = 1
    }

    private let clearButton = UIButton(type: .system)
    private let doneButton = UIButton(type: .system)
    private var clearAction: (() -> Void)?
    private var doneAction: (() -> Void)?
    private var clearWidthConstraint: NSLayoutConstraint?
    private var clearHeightConstraint: NSLayoutConstraint?
    private var doneWidthConstraint: NSLayoutConstraint?
    private var doneHeightConstraint: NSLayoutConstraint?

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
            height: currentButtonSize + Layout.verticalPadding * 2
        )
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
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        clearAction?()
    }

    @objc private func handleDoneTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
        clearWidthConstraint = clearButton.widthAnchor.constraint(equalToConstant: currentButtonSize)
        clearHeightConstraint = clearButton.heightAnchor.constraint(equalToConstant: currentButtonSize)
        doneWidthConstraint = doneButton.widthAnchor.constraint(equalToConstant: currentButtonSize)
        doneHeightConstraint = doneButton.heightAnchor.constraint(equalToConstant: currentButtonSize)

        let constraints: [NSLayoutConstraint?] = [
            clearButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.sidePadding),
            clearButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            clearWidthConstraint,
            clearHeightConstraint,

            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.sidePadding),
            doneButton.centerYAnchor.constraint(equalTo: clearButton.centerYAnchor),
            doneWidthConstraint,
            doneHeightConstraint
        ]
        NSLayoutConstraint.activate(constraints.compactMap { $0 })
    }

    private func applyStyle() {
        let buttonSize = currentButtonSize
        let symbolConfig = currentSymbolConfiguration
        let backgroundColor = UIColor.secondarySystemBackground
        let borderColor = UIColor.separator.withAlphaComponent(0.8).cgColor
        let tintColor = UIColor.label

        clearWidthConstraint?.constant = buttonSize
        clearHeightConstraint?.constant = buttonSize
        doneWidthConstraint?.constant = buttonSize
        doneHeightConstraint?.constant = buttonSize

        clearButton.setPreferredSymbolConfiguration(symbolConfig, forImageIn: .normal)
        doneButton.setPreferredSymbolConfiguration(symbolConfig, forImageIn: .normal)

        clearButton.backgroundColor = backgroundColor
        clearButton.tintColor = tintColor
        clearButton.layer.cornerRadius = buttonSize / 2
        clearButton.layer.borderWidth = Layout.borderWidth
        clearButton.layer.borderColor = borderColor

        doneButton.backgroundColor = backgroundColor
        doneButton.tintColor = tintColor
        doneButton.layer.cornerRadius = buttonSize / 2
        doneButton.layer.borderWidth = Layout.borderWidth
        doneButton.layer.borderColor = borderColor

        invalidateIntrinsicContentSize()
    }

    private var currentButtonSize: CGFloat {
        traitCollection.userInterfaceIdiom == .pad ? Layout.buttonSizePad : Layout.buttonSizePhone
    }

    private var currentSymbolConfiguration: UIImage.SymbolConfiguration {
        let size: CGFloat = traitCollection.userInterfaceIdiom == .pad ? 20 : 16
        return UIImage.SymbolConfiguration(pointSize: size, weight: .semibold)
    }
}
