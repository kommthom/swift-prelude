extension Unit: Equatable {
    public static func == (_: Unit, _: Unit) -> Bool {
        return true
    }
}

public func equal<A: Equatable & Sendable>(to a: A) -> @Sendable (A) -> Bool {
    return curry(
        { $0 == $1 }
        )
        <|
        a
}

public func == <A: Sendable, B: Equatable & Sendable>(f: @escaping @Sendable (A) -> B, g: @escaping @Sendable (A) -> B) -> (A) -> Bool {
    return { a in f(a) == g(a) }
}

public func != <A: Sendable, B: Equatable & Sendable>(f: @escaping @Sendable (A) -> B, g: @escaping @Sendable (A) -> B) -> @Sendable (A) -> Bool {
    return { a in f(a) != g(a) }
}

public func == <A: Sendable, B: Equatable & Sendable>(f: @escaping @Sendable (A) -> B, x: B) -> @Sendable (A) -> Bool {
    return { a in return f(a) == x }
}

public func != <A: Sendable, B: Equatable & Sendable>(f: @escaping @Sendable (A) -> B, x: B) -> @Sendable (A) -> Bool {
    return f != const(x)
}
