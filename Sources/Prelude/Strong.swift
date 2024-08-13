public func first<A: Sendable, B: Sendable, C: Sendable>(_ a2b: @escaping @Sendable (A) -> B) -> @Sendable ((A, C)) -> (B, C) {
    return { ac in
        (
            a2b(ac.0),
            ac.1
        ) }
}

public func second<A: Sendable, B: Sendable, C: Sendable>(_ b2c: @escaping @Sendable (B) -> C) -> @Sendable ((A, B)) -> (A, C) {
    return { ab in (ab.0, b2c(ab.1)) }
}
