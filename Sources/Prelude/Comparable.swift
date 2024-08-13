extension Comparable {
    public static func compare(_ x: Self, _ y: Self) -> Comparator {
        if x == y {
            return .eq
        } else if x < y {
            return .lt
        } else { // x > y
            return .gt
        }
    }
}

public func compare<A: Comparable & Sendable>(_ a: A) -> (A) -> Comparator {
    return curry(
        { A.compare($0, $1) }
        )
        <|
        a
}

extension Bool: Comparable {
    public static func < (lhs: Bool, rhs: Bool) -> Bool {
        return (lhs, rhs) == (false, true)
    }
}

extension Unit: Comparable {
    public static func < (_: Unit, _: Unit) -> Bool {
        return false
    }
}

public func lessThan<A: Comparable & Sendable>(_ a: A) -> @Sendable (A) -> Bool {
    return flip(
            curry(
                { $0 < $1 }
            )
        )
        <|
        a
}

public func lessThanOrEqual<A: Comparable & Sendable>(to a: A) -> @Sendable (A) -> Bool {
    return flip(
            curry(
                { $0 <= $1 }
            )
        )
        <|
        a
}

public func greaterThan<A: Comparable & Sendable>(_ a: A) -> @Sendable (A) -> Bool {
    return flip(
            curry(
                { $0 > $1 }
            )
        )
        <|
        a
}

public func greaterThanOrEqual<A: Comparable & Sendable>(to a: A) -> @Sendable (A) -> Bool {
    return flip(
            curry(
                { $0 >= $1 }
            )
        )
        <|
        a
}

public func < <A: Sendable, B: Comparable & Sendable>(f: @escaping @Sendable (A) -> B, x: B) -> @Sendable (A) -> Bool {
    return f >>> lessThan(x)
}

public func <= <A: Sendable, B: Comparable & Sendable>(f: @escaping @Sendable (A) -> B, x: B) -> @Sendable (A) -> Bool {
    return f >>> lessThanOrEqual(to: x)
}

public func > <A: Sendable, B: Comparable & Sendable>(f: @escaping @Sendable (A) -> B, x: B) -> @Sendable (A) -> Bool {
    return f >>> greaterThan(x)
}

public func >= <A: Sendable, B: Comparable & Sendable>(f: @escaping @Sendable (A) -> B, x: B) -> @Sendable (A) -> Bool {
    return f >>> greaterThanOrEqual(to: x)
}

public func clamp<T: Sendable>(_ to: CountableClosedRange<T>) -> @Sendable (T) -> T {
    return { element in
        min(to.upperBound, max(to.lowerBound, element))
    }
}

public func clamp<T: Sendable>(_ to: CountableRange<T>) -> @Sendable (T) -> T {
    return { element in
        min(to.upperBound.advanced(by: -1), max(to.lowerBound, element))
    }
}

public func their<A: Sendable, B: Sendable>(_ f: @escaping @Sendable (A) -> B, _ g: @escaping @Sendable (B, B) -> Bool) -> @Sendable (A, A) -> Bool {
    return { g(f($0), f($1)) }
}

public func their<A: Sendable, B: Comparable & Sendable>(_ f: @escaping @Sendable (A) -> B) -> @Sendable (A, A) -> Bool {
    return their(
        f,
        { $0 < $1 }
    )
}
