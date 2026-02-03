import SwiftUI
import UIKit

struct HorizontalWheelPicker: UIViewRepresentable {
    let options: [Int]
    @Binding var selection: Int
    let itemWidth: CGFloat
    let itemHeight: CGFloat
    let itemSpacing: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = itemSpacing

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.allowsSelection = true
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        collectionView.register(NumberCell.self, forCellWithReuseIdentifier: NumberCell.reuseId)
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = context.coordinator
        collectionView.addGestureRecognizer(tap)
        return collectionView
    }

    func updateUIView(_ uiView: UICollectionView, context: Context) {
        context.coordinator.parent = self

        if let layout = uiView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            layout.minimumLineSpacing = itemSpacing
        }

        let inset = max(0, (uiView.bounds.width - itemWidth) / 2)
        if uiView.contentInset.left != inset || uiView.contentInset.right != inset {
            uiView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        }

        uiView.reloadData()
        context.coordinator.scrollToSelectionIfNeeded(in: uiView, animated: false)
        context.coordinator.updateVisibleCells(in: uiView)
    }
}

extension HorizontalWheelPicker {
    final class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {
        var parent: HorizontalWheelPicker
        private var lastSelection: Int?
        private var pendingIndex: Int?
        private var isUserDragging = false

        init(_ parent: HorizontalWheelPicker) {
            self.parent = parent
        }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            parent.options.count
        }

        func collectionView(
            _ collectionView: UICollectionView,
            cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NumberCell.reuseId,
                for: indexPath
            ) as? NumberCell else {
                return UICollectionViewCell()
            }
            cell.configure(text: "\(parent.options[indexPath.item])")
            let highlightIndex = parent.options.firstIndex(of: parent.selection)
            cell.setHighlighted(indexPath.item == highlightIndex)
            return cell
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard let collectionView = scrollView as? UICollectionView else { return }
            if isUserDragging {
                let index = nearestIndex(in: collectionView)
                let value = parent.options[index]
                if parent.selection != value {
                    parent.selection = value
                }
            }
            updateVisibleCells(in: collectionView)
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            isUserDragging = true
        }

        func scrollViewWillEndDragging(
            _ scrollView: UIScrollView,
            withVelocity velocity: CGPoint,
            targetContentOffset: UnsafeMutablePointer<CGPoint>
        ) {
            guard let collectionView = scrollView as? UICollectionView else { return }
            let index = nearestIndex(
                contentOffsetX: targetContentOffset.pointee.x,
                in: collectionView
            )
            // Cancel default deceleration to avoid delayed snap.
            targetContentOffset.pointee = scrollView.contentOffset
            pendingIndex = index
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            finalizeSelection(in: scrollView, animated: true)
            if !decelerate {
                isUserDragging = false
            }
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            finalizeSelection(in: scrollView, animated: false)
            isUserDragging = false
        }

        func scrollToSelectionIfNeeded(in collectionView: UICollectionView, animated: Bool) {
            if isUserDragging {
                updateVisibleCells(in: collectionView)
                return
            }
            guard let index = parent.options.firstIndex(of: parent.selection) else { return }
            if lastSelection == parent.selection, collectionView.numberOfItems(inSection: 0) > 0 {
                return
            }
            let offset = offsetForIndex(index, in: collectionView)
            collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
            lastSelection = parent.selection
        }

        func updateVisibleCells(in collectionView: UICollectionView) {
            let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
            let highlightIndex = nearestIndex(in: collectionView)
            for cell in collectionView.visibleCells {
                guard let indexPath = collectionView.indexPath(for: cell),
                      let numberCell = cell as? NumberCell else { continue }
                let distance = abs(cell.center.x - centerX)
                let maxDistance = max(collectionView.bounds.width / 2, 1)
                let normalized = min(distance / maxDistance, 1)
                let scale = 1 - 0.2 * normalized
                let alpha = 1 - 0.6 * normalized
                let isHighlighted = indexPath.item == highlightIndex

                cell.layer.transform = CATransform3DIdentity
                cell.transform = CGAffineTransform(scaleX: scale, y: scale)
                cell.alpha = alpha
                numberCell.setHighlighted(isHighlighted)
            }
        }

        private func finalizeSelection(in scrollView: UIScrollView, animated: Bool) {
            guard let collectionView = scrollView as? UICollectionView else { return }
            let index = pendingIndex ?? nearestIndex(in: collectionView)
            pendingIndex = nil
            let targetOffset = offsetForIndex(index, in: collectionView)
            if abs(collectionView.contentOffset.x - targetOffset) > 0.5 {
                collectionView.setContentOffset(CGPoint(x: targetOffset, y: 0), animated: animated)
            }
            let value = parent.options[index]
            if parent.selection != value {
                parent.selection = value
            }
            lastSelection = value
            updateVisibleCells(in: collectionView)
        }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            selectIndex(indexPath.item, in: collectionView, animated: true)
        }

        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let collectionView = recognizer.view as? UICollectionView else { return }
            let location = recognizer.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: location) {
                selectIndex(indexPath.item, in: collectionView, animated: true)
                return
            }

            let index = nearestIndex(in: collectionView)
            selectIndex(index, in: collectionView, animated: true)
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            true
        }

        private func nearestIndex(in collectionView: UICollectionView) -> Int {
            nearestIndex(contentOffsetX: collectionView.contentOffset.x, in: collectionView)
        }

        private func nearestIndex(contentOffsetX: CGFloat, in collectionView: UICollectionView) -> Int {
            let itemStep = parent.itemWidth + parent.itemSpacing
            let offsetX = contentOffsetX + collectionView.contentInset.left
            let rawIndex = Int(round(offsetX / itemStep))
            return min(max(rawIndex, 0), max(parent.options.count - 1, 0))
        }

        private func offsetForIndex(_ index: Int, in collectionView: UICollectionView) -> CGFloat {
            let itemStep = parent.itemWidth + parent.itemSpacing
            return CGFloat(index) * itemStep - collectionView.contentInset.left
        }

        private func selectIndex(_ index: Int, in collectionView: UICollectionView, animated: Bool) {
            let offset = offsetForIndex(index, in: collectionView)
            collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
            let value = parent.options[index]
            if parent.selection != value {
                parent.selection = value
            }
            lastSelection = value
        }
    }
}

private final class NumberCell: UICollectionViewCell {
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
        let textStyle: UIFont.TextStyle = isSelected ? .title3 : .body
        label.font = UIFont.preferredFont(forTextStyle: textStyle)
        let color: UIColor = isSelected ? .white : .placeholderText
        label.textColor = color
        backgroundContainer.layer.borderColor = color.withAlphaComponent(0.7).cgColor
        backgroundContainer.backgroundColor = isSelected ? UIColor.label.withAlphaComponent(0.08) : .clear
    }

    func setHighlighted(_ isHighlighted: Bool) {
        setSelected(isHighlighted)
    }
}
