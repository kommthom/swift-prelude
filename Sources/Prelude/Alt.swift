public protocol Alt {
    static func <|>(lhs: Self, rhs: @autoclosure @escaping @Sendable () -> Self) -> Self
}

extension Array: Alt {
    public static func <|>(lhs: Array, rhs: @autoclosure @escaping @Sendable () -> Array) -> Array {
        return lhs + rhs()
    }
}

extension Optional: Alt {
    public static func <|>(lhs: Optional, rhs: @autoclosure @escaping @Sendable () -> Optional) -> Optional {
        return lhs ?? rhs()
    }
}
