import SwiftUI
import DesignSystem

enum MenuLayout {
    case regular
    case compact
    case ultraCompact

    var headerSpacing: CGFloat {
        switch self {
        case .regular:
            return DesignSystem.Spacing.small
        case .compact, .ultraCompact:
            return DesignSystem.Spacing.small
        }
    }
}
