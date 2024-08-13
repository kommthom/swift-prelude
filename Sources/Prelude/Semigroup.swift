public protocol Semigroup: Sendable {
    static func <> (lhs: Self, rhs: Self) -> Self
}

public prefix func <> <S: Semigroup>(rhs: S) -> @Sendable (S) -> S {
    return { lhs in lhs <> rhs }
}

public postfix func <> <S: Semigroup>(lhs: S) -> @Sendable (S) -> S {
    return { rhs in lhs <> rhs }
}

public func concat<S: Sequence & Sendable>(_ xs: S, _ e: S.Element) -> S.Element where S.Element: Semigroup {
    return xs.reduce(e, <>)
}

extension String: Semigroup {
    public static func <> (lhs: String, rhs: String) -> String {
        return lhs + rhs
    }
}

extension Array: Semigroup where Element == Sendable {
    public static func <> (lhs: Array, rhs: Array) -> Array {
        return lhs + rhs
    }
}
// Swift6: Element does not conform to Sendable
//extension Set: AsyncSemigroup { //where Element == Sendable {
//    public static func <>(
//        lhs: Set,
//        rhs: Set
//    ) -> Set {
//      return lhs.union(rhs)
//    }
//}
//
public func <> <A: Sendable>(lhs: @escaping @Sendable (A) -> A, rhs: @escaping @Sendable (A) -> A) -> @Sendable (A) -> A {
    return lhs >>> rhs
}
