extension WheelPicker {
    enum HoverState: Equatable {
        case disabled
        case enabled([Int: Bool])

        // MARK: Internal

        static var enabledEmpty = HoverState.enabled([:])

        var isEnabled: Bool {
            switch self {
            case .enabled:
                return true
            case .disabled:
                return false
            }
        }

        var hoveringAppIndex: Int? {
            switch self {
            case let .enabled(hoverDictionary):
                return hoverDictionary.first(where: { $0.value })?.key
            case .disabled:
                return nil
            }
        }

        func isHovering(appIndex: Int) -> Bool {
            switch self {
            case let .enabled(hoverDictionary):
                return hoverDictionary[appIndex] ?? false
            case .disabled:
                return false
            }
        }

        mutating func set(isHovering: Bool, at appIndex: Int) {
            switch self {
            case var .enabled(hoverDictionary):
                hoverDictionary[appIndex] = isHovering
                self = .enabled(hoverDictionary)
            case .disabled:
                break
            }
        }
    }
}
