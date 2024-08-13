public func id<A: Sendable>(_ a: A) -> A {
    return a
}

public func <<< <A: Sendable, B: Sendable, C: Sendable>(_ b2c: @escaping @Sendable (B) -> C, _ a2b: @escaping @Sendable (A) -> B) -> @Sendable (A) -> C {
    return { a in b2c(a2b(a)) }
}

public func >>> <A: Sendable, B: Sendable, C: Sendable>(_ a2b: @escaping @Sendable (A) -> B, _ b2c: @escaping @Sendable (B) -> C) -> @Sendable (A) -> C {
    return { a in b2c(a2b(a)) }
}

public func const<A: Sendable, B: Sendable>(_ a: A) -> @Sendable (B) -> A {
    return { _ in a }
}

public func <| <A: Sendable, B: Sendable> (f: @Sendable (A) -> B, a: A) -> B {
    return f(a)
}

public func |> <A: Sendable, B: Sendable> (a: A, f: @Sendable (A) -> B) -> B {
    return f(a)
}

public func flip<A: Sendable, B: Sendable, C: Sendable>(_ f: @escaping @Sendable (A) -> @Sendable (B) -> C) -> @Sendable (B) -> @Sendable (A) -> C {
    return { b in { a in
        f(a)(b)
    } }
}

// MARK: - Bind/Monad

public func flatMap <A: Sendable, B: Sendable, C: Sendable>(_ lhs: @escaping @Sendable (B) -> ((A) -> C), _ rhs: @escaping @Sendable (A) -> B) -> @Sendable (A) -> C {
    return { a in
        lhs(rhs(a))(a)
    }
}

public func >=> <A: Sendable, B: Sendable, C: Sendable, D: Sendable>(lhs: @escaping @Sendable (A) -> (@Sendable (D) -> B), rhs: @escaping @Sendable (B) -> (@Sendable (D) -> C)) -> @Sendable (A)  -> (@Sendable (D) -> C) {
    return { a in
        flatMap(rhs, lhs(a))
    }
}
