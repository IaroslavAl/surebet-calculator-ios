import SwiftUI
import DesignSystem

enum MenuLayout {
    case regular
    case compact
    case ultraCompact

    var showsHeader: Bool { self != .ultraCompact }
    var showsHeaderSubtitle: Bool { self == .regular }
    var showsPrimarySubtitle: Bool { self != .ultraCompact }
    var showsSecondarySubtitle: Bool { self == .regular }

    var headerSpacing: CGFloat {
        switch self {
        case .regular:
            return DesignSystem.Spacing.small
        case .compact, .ultraCompact:
            return DesignSystem.Spacing.small
        }
    }
}
