import UIKit

final class HorizontalWheelPickerNumberCell: UICollectionViewCell {
    static let reuseId = "HorizontalWheelPickerNumberCell"

    private let label = UILabel()
    private let backgroundContainer = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundContainer.translatesAutoresizingMaskIntoConstraints = false
        backgroundContainer.backgroundColor = .clear
        backgroundContainer.layer.cornerRadius = 12
        backgroundContainer.layer.borderWidth = 2
        backgroundContainer.layer.masksToBounds = true

        label.textAlignment = .center
        label.textColor = .placeholderText
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.minimumScaleFactor = 0.7
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backgroundContainer)
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            backgroundContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        return nil
    }

    func configure(text: String) {
        label.text = text
    }

    func setSelected(_ isSelected: Bool) {
        let textStyle: UIFont.TextStyle
        if traitCollection.userInterfaceIdiom == .pad {
            textStyle = isSelected ? .title1 : .title2
        } else {
            textStyle = isSelected ? .title3 : .body
        }
        label.font = UIFont.preferredFont(forTextStyle: textStyle)

        if isSelected {
            label.textColor = .label
            backgroundContainer.layer.borderColor = UIColor.label.withAlphaComponent(0.6).cgColor
            backgroundContainer.backgroundColor = UIColor.secondarySystemFill
        } else {
            label.textColor = .placeholderText
            backgroundContainer.layer.borderColor = UIColor.separator.withAlphaComponent(0.8).cgColor
            backgroundContainer.backgroundColor = .clear
        }
    }

    func setHighlighted(_ isHighlighted: Bool) {
        setSelected(isHighlighted)
    }
}
