import Foundation

@MainActor
struct PresentationBinding {
    var value: Bool {
        get { getValue() }
        nonmutating set { setValue(newValue) }
    }

    private let getValue: () -> Bool
    private let setValue: (Bool) -> Void

    init(
        getValue: @escaping () -> Bool,
        setValue: @escaping (Bool) -> Void
    ) {
        self.getValue = getValue
        self.setValue = setValue
    }

    static func constant(_ value: Bool) -> PresentationBinding {
        PresentationBinding(getValue: { value }, setValue: { _ in })
    }
}
