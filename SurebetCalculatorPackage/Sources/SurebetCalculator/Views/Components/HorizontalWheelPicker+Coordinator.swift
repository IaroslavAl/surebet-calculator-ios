import UIKit

extension HorizontalWheelPicker {
    @MainActor
    final class Coordinator: NSObject {
        var parent: HorizontalWheelPicker
        private var lastSelection: Int?
        private var pendingIndex: Int?
        private var isUserDragging = false
        private var isDecelerating = false
        private var pendingSelection: Int?
        private var isSelectionUpdateScheduled = false
        private var lastOptions: [Int] = []
        private var lastItemWidth: CGFloat = .zero
        private var lastItemHeight: CGFloat = .zero
        private var lastItemSpacing: CGFloat = .zero
        private var lastBoundsWidth: CGFloat = .zero
        private var lastInset: CGFloat = .zero
        private let repeatMultiplier = 200
        private let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        private var lastHapticIndex: Int?
        var hasCentered = false
        var isCenteringScheduled = false

        init(_ parent: HorizontalWheelPicker) {
            self.parent = parent
        }
    }
}

extension HorizontalWheelPicker.Coordinator: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalItemCount()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HorizontalWheelPickerNumberCell.reuseId,
            for: indexPath
        ) as? HorizontalWheelPickerNumberCell else {
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
}

extension HorizontalWheelPicker.Coordinator: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        impactFeedback.prepare()
        selectListIndex(indexPath.item, in: collectionView, animated: true, emitHaptic: true)
    }
}

extension HorizontalWheelPicker.Coordinator: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else { return }
        let index = nearestIndex(in: collectionView)
        if isUserDragging || isDecelerating {
            if let value = optionValue(for: index), value != parent.selection {
                scheduleSelectionUpdate(value)
            }
            emitStepHapticsIfNeeded(from: lastHapticIndex, to: index)
            lastHapticIndex = index
        }
        updateVisibleCells(in: collectionView)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isUserDragging = true
        isDecelerating = false
        if let collectionView = scrollView as? UICollectionView {
            lastHapticIndex = nearestIndex(in: collectionView)
        }
        impactFeedback.prepare()
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
        let shouldSnap = abs(velocity.x) < 0.35
        if shouldSnap {
            targetContentOffset.pointee.x = offsetForIndex(index, in: collectionView)
            pendingIndex = index
        } else {
            pendingIndex = nil
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            isUserDragging = false
        } else {
            finalizeSelection(in: scrollView, animated: true)
            isUserDragging = false
            isDecelerating = false
        }
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        isDecelerating = true
        impactFeedback.prepare()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        finalizeSelection(in: scrollView, animated: false)
        isUserDragging = false
        isDecelerating = false
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else { return }
        updateVisibleCells(in: collectionView)
    }
}

extension HorizontalWheelPicker.Coordinator: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}

extension HorizontalWheelPicker.Coordinator {
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let collectionView = recognizer.view as? UICollectionView else { return }
        let location = recognizer.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: location) {
            impactFeedback.prepare()
            selectListIndex(indexPath.item, in: collectionView, animated: true, emitHaptic: true)
            return
        }

        let index = nearestIndex(in: collectionView)
        impactFeedback.prepare()
        selectListIndex(index, in: collectionView, animated: true, emitHaptic: true)
    }
}

extension HorizontalWheelPicker.Coordinator {
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
                  let numberCell = cell as? HorizontalWheelPickerNumberCell else { continue }
            let distance = abs(cell.center.x - centerX)
            let maxDistance = max(collectionView.bounds.width / 2, 1)
            let normalized = min(distance / maxDistance, 1)
            let isHighlighted = indexPath.item == highlightIndex
            let scale = isHighlighted ? 1 : 1 - 0.2 * normalized
            let alpha = isHighlighted ? 1 : 1 - 0.6 * normalized

            cell.layer.transform = CATransform3DIdentity
            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            cell.alpha = alpha
            numberCell.setHighlighted(isHighlighted)
        }
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

    func centerOnSelection(in collectionView: UICollectionView) {
        guard let optionIndex = parent.options.firstIndex(of: parent.selection) else { return }
        let listIndex = centeredIndex(forOptionIndex: optionIndex)
        let offset = offsetForIndex(listIndex, in: collectionView)
        collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
        lastSelection = parent.selection
        hasCentered = true
    }
}

private extension HorizontalWheelPicker.Coordinator {
    func finalizeSelection(in scrollView: UIScrollView, animated: Bool) {
        guard let collectionView = scrollView as? UICollectionView else { return }
        let index = pendingIndex ?? nearestIndex(in: collectionView)
        pendingIndex = nil
        guard let optionIndex = optionIndex(for: index) else { return }
        let centered = centeredIndex(forOptionIndex: optionIndex)
        let distance = index >= centered ? index - centered : centered - index
        let targetIndex = distance > parent.options.count * 2 ? centered : index
        selectListIndex(targetIndex, in: collectionView, animated: animated)
        updateVisibleCells(in: collectionView)
    }

    func nearestIndex(in collectionView: UICollectionView) -> Int {
        nearestIndex(contentOffsetX: collectionView.contentOffset.x, in: collectionView)
    }

    func nearestIndex(contentOffsetX: CGFloat, in collectionView: UICollectionView) -> Int {
        guard totalItemCount() > 0 else { return 0 }
        let itemStep = parent.itemWidth + parent.itemSpacing
        let offsetX = contentOffsetX + collectionView.contentInset.left
        let rawIndex = Int(round(offsetX / itemStep))
        return min(max(rawIndex, 0), totalItemCount() - 1)
    }

    func offsetForIndex(_ index: Int, in collectionView: UICollectionView) -> CGFloat {
        let itemStep = parent.itemWidth + parent.itemSpacing
        return CGFloat(index) * itemStep - collectionView.contentInset.left
    }

    func selectListIndex(
        _ index: Int,
        in collectionView: UICollectionView,
        animated: Bool,
        emitHaptic: Bool = false
    ) {
        let offset = offsetForIndex(index, in: collectionView)
        if abs(collectionView.contentOffset.x - offset) > 0.5 {
            collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
        }
        if let value = optionValue(for: index) {
            if emitHaptic {
                impactFeedback.impactOccurred(intensity: 0.5)
                impactFeedback.prepare()
            }
            scheduleSelectionUpdate(value)
            lastSelection = value
            lastHapticIndex = index
        }
    }

    func emitStepHapticsIfNeeded(from previousIndex: Int?, to currentIndex: Int) {
        guard let previousIndex, previousIndex != currentIndex else { return }
        let step = currentIndex > previousIndex ? 1 : -1
        var index = previousIndex + step
        while index != currentIndex + step {
            impactFeedback.impactOccurred(intensity: 0.5)
            impactFeedback.prepare()
            index += step
        }
    }

    func scheduleSelectionUpdate(_ value: Int) {
        pendingSelection = value
        guard !isSelectionUpdateScheduled else { return }
        isSelectionUpdateScheduled = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isSelectionUpdateScheduled = false
            guard let value = self.pendingSelection else { return }
            self.pendingSelection = nil
            self.lastSelection = value
            if self.parent.selection != value {
                self.parent.selection = value
            }
        }
    }

    func totalItemCount() -> Int {
        totalItemCount(for: parent.options)
    }

    func totalItemCount(for options: [Int]) -> Int {
        let count = options.count
        guard count > 0 else { return 0 }
        return count * repeatMultiplier
    }

    func optionIndex(for listIndex: Int) -> Int? {
        let count = parent.options.count
        guard count > 0 else { return nil }
        return listIndex % count
    }

    func optionValue(for listIndex: Int) -> Int? {
        guard let index = optionIndex(for: listIndex) else { return nil }
        return parent.options[index]
    }

    func centeredIndex(forOptionIndex optionIndex: Int) -> Int {
        let count = parent.options.count
        guard count > 0 else { return 0 }
        let base = (repeatMultiplier / 2) * count
        return base + optionIndex
    }
}
