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

        let collectionView = HorizontalWheelPickerCollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .normal
        collectionView.allowsSelection = true
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        collectionView.onLayout = { [weak collectionView, weak coordinator = context.coordinator] in
            guard let collectionView, let coordinator else { return }
            coordinator.handleLayoutChange(in: collectionView)
        }
        collectionView.register(
            HorizontalWheelPickerNumberCell.self,
            forCellWithReuseIdentifier: HorizontalWheelPickerNumberCell.reuseId
        )
        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
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

final class HorizontalWheelPickerCollectionView: UICollectionView {
    var onLayout: (() -> Void)?
    private var lastBoundsSize: CGSize = .zero

    override func layoutSubviews() {
        super.layoutSubviews()
        let currentSize = bounds.size
        guard currentSize != lastBoundsSize else { return }
        lastBoundsSize = currentSize
        onLayout?()
    }
}
