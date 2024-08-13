public enum Comparator: Sendable {
    case lt
    case gt
    case eq
}

extension Comparator: Equatable {
    public static func == (lhs: Comparator, rhs: Comparator) -> Bool {
        return switch (lhs, rhs) {
            case (.lt, .lt), (.gt, .gt), (.eq, eq): true
            default: false
        }
    }
}

extension Comparator: Comparable {
    public static func < (lhs: Comparator, rhs: Comparator) -> Bool {
        return switch (lhs, rhs) {
            case (.lt, .lt): false
            case (.lt, _), (.eq, .gt): true
            default: false
        }
    }
}

extension Comparator: Semigroup {
    public static func <> (lhs: Comparator, rhs: Comparator) -> Comparator {
        return switch (lhs, rhs) {
            case (.lt, _): .lt
            case (.gt, _): .gt
            case let (.eq, r): r
        }
    }
}

public func inverted(_ ordering: Comparator) -> Comparator {
    return switch ordering {
        case .lt: .gt
        case .gt: .lt
        case .eq: .eq
    }
}
