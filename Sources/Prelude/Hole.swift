public func hole<A: Sendable>() -> A {
    fatalError()
}

public func hole<A: Sendable, B: Sendable>(_ a: A) -> B {
    fatalError()
}

public func hole<A: Sendable, B: Sendable, C: Sendable>(_ a: A, _ b: B) -> C {
    fatalError()
}

public func hole<A: Sendable, B: Sendable, C: Sendable, D: Sendable>(_ a: A, _ b: B, _ c: C) -> D {
    fatalError()
}

public func hole<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable>(_ a: A, _ b: B, _ c: C, _ d: D) -> E {
    fatalError()
}
