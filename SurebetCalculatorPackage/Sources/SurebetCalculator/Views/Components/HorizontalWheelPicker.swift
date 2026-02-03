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
            if context.coordinator.updateLayoutIfNeeded(
                itemWidth: itemWidth,
                itemHeight: itemHeight,
                itemSpacing: itemSpacing
            ) {
                layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
                layout.minimumLineSpacing = itemSpacing
                layout.invalidateLayout()
            }
        }

        let inset = max(0, (uiView.bounds.width - itemWidth) / 2)
        if context.coordinator.updateInsetIfNeeded(
            inset: inset,
            boundsWidth: uiView.bounds.width
        ) {
            uiView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        }

        if context.coordinator.shouldReload(options: options, currentCount: uiView.numberOfItems(inSection: 0)) {
            uiView.reloadData()
        }
        if !context.coordinator.hasCentered {
            if uiView.bounds.width > 0 {
                context.coordinator.centerOnSelection(in: uiView)
            } else if !context.coordinator.isCenteringScheduled {
                context.coordinator.isCenteringScheduled = true
                DispatchQueue.main.async { [weak uiView] in
                    guard let uiView else { return }
                    if uiView.bounds.width > 0 {
                        context.coordinator.centerOnSelection(in: uiView)
                    }
                    context.coordinator.isCenteringScheduled = false
                }
            }
        } else {
            context.coordinator.scrollToSelectionIfNeeded(in: uiView, animated: false)
        }
        context.coordinator.updateVisibleCells(in: uiView)
    }
}

extension HorizontalWheelPicker {
    final class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {
        var parent: HorizontalWheelPicker
        private var lastSelection: Int?
        private var pendingIndex: Int?
        private var isUserDragging = false
        private var lastOptions: [Int] = []
        private var lastItemWidth: CGFloat = .zero
        private var lastItemHeight: CGFloat = .zero
        private var lastItemSpacing: CGFloat = .zero
        private var lastBoundsWidth: CGFloat = .zero
        private var lastInset: CGFloat = .zero
        private let repeatMultiplier = 200
        var hasCentered = false
        var isCenteringScheduled = false

        init(_ parent: HorizontalWheelPicker) {
            self.parent = parent
        }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            totalItemCount()
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
            if let option = optionValue(for: indexPath.item) {
                cell.configure(text: "\(option)")
            } else {
                cell.configure(text: "")
            }
            cell.setHighlighted(false)
            return cell
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard let collectionView = scrollView as? UICollectionView else { return }
            if isUserDragging {
                if let value = optionValue(for: nearestIndex(in: collectionView)) {
                    if parent.selection != value {
                        parent.selection = value
                    }
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
            guard let optionIndex = parent.options.firstIndex(of: parent.selection) else { return }
            if lastSelection == parent.selection, collectionView.numberOfItems(inSection: 0) > 0 {
                return
            }
            let listIndex = centeredIndex(forOptionIndex: optionIndex)
            let offset = offsetForIndex(listIndex, in: collectionView)
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
            guard let optionIndex = optionIndex(for: index) else { return }
            let centered = centeredIndex(forOptionIndex: optionIndex)
            let targetIndex = abs(index - centered) > parent.options.count * 2 ? centered : index
            selectListIndex(targetIndex, in: collectionView, animated: animated)
            updateVisibleCells(in: collectionView)
        }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            selectListIndex(indexPath.item, in: collectionView, animated: true)
        }

        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let collectionView = recognizer.view as? UICollectionView else { return }
            let location = recognizer.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: location) {
                selectListIndex(indexPath.item, in: collectionView, animated: true)
                return
            }

            let index = nearestIndex(in: collectionView)
            selectListIndex(index, in: collectionView, animated: true)
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            true
        }

        func shouldReload(options: [Int], currentCount: Int) -> Bool {
            let totalCount = totalItemCount(for: options)
            if currentCount != totalCount {
                lastOptions = options
                lastSelection = nil
                hasCentered = false
                isCenteringScheduled = false
                return true
            }
            if lastOptions != options {
                lastOptions = options
                lastSelection = nil
                hasCentered = false
                isCenteringScheduled = false
                return true
            }
            return false
        }

        func updateLayoutIfNeeded(itemWidth: CGFloat, itemHeight: CGFloat, itemSpacing: CGFloat) -> Bool {
            if lastItemWidth != itemWidth || lastItemHeight != itemHeight || lastItemSpacing != itemSpacing {
                lastItemWidth = itemWidth
                lastItemHeight = itemHeight
                lastItemSpacing = itemSpacing
                return true
            }
            return false
        }

        func updateInsetIfNeeded(inset: CGFloat, boundsWidth: CGFloat) -> Bool {
            if lastBoundsWidth != boundsWidth || lastInset != inset {
                lastBoundsWidth = boundsWidth
                lastInset = inset
                return true
            }
            return false
        }

        private func nearestIndex(in collectionView: UICollectionView) -> Int {
            nearestIndex(contentOffsetX: collectionView.contentOffset.x, in: collectionView)
        }

        private func nearestIndex(contentOffsetX: CGFloat, in collectionView: UICollectionView) -> Int {
            guard totalItemCount() > 0 else { return 0 }
            let itemStep = parent.itemWidth + parent.itemSpacing
            let offsetX = contentOffsetX + collectionView.contentInset.left
            let rawIndex = Int(round(offsetX / itemStep))
            return min(max(rawIndex, 0), totalItemCount() - 1)
        }

        private func offsetForIndex(_ index: Int, in collectionView: UICollectionView) -> CGFloat {
            let itemStep = parent.itemWidth + parent.itemSpacing
            return CGFloat(index) * itemStep - collectionView.contentInset.left
        }

        private func selectListIndex(_ index: Int, in collectionView: UICollectionView, animated: Bool) {
            let offset = offsetForIndex(index, in: collectionView)
            collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
            if let value = optionValue(for: index) {
                if parent.selection != value {
                    parent.selection = value
                }
                lastSelection = value
            }
        }

        private func totalItemCount() -> Int {
            totalItemCount(for: parent.options)
        }

        private func totalItemCount(for options: [Int]) -> Int {
            let count = options.count
            guard count > 0 else { return 0 }
            return count * repeatMultiplier
        }

        private func optionIndex(for listIndex: Int) -> Int? {
            let count = parent.options.count
            guard count > 0 else { return nil }
            return listIndex % count
        }

        private func optionValue(for listIndex: Int) -> Int? {
            guard let index = optionIndex(for: listIndex) else { return nil }
            return parent.options[index]
        }

        private func centeredIndex(forOptionIndex optionIndex: Int) -> Int {
            let count = parent.options.count
            guard count > 0 else { return 0 }
            let base = (repeatMultiplier / 2) * count
            return base + optionIndex
        }

        func centerOnSelection(in collectionView: UICollectionView) {
            guard let optionIndex = parent.options.firstIndex(of: parent.selection) else { return }
            let listIndex = centeredIndex(forOptionIndex: optionIndex)
            let offset = offsetForIndex(listIndex, in: collectionView)
            collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
            lastSelection = parent.selection
            hasCentered = true
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
