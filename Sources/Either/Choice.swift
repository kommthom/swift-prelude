public func left<A: Sendable, B: Sendable, C: Sendable>(_ a2b: @escaping @Sendable (A) -> B) -> (Either<A, C>) -> Either<B, C> {
    return { either in
        switch either {
            case let .left(a):
                return .left(a2b(a))
            case let .right(c):
                return .right(c)
            }
        }
}

public func right<A: Sendable, B: Sendable, C: Sendable>(_ b2c: @escaping @Sendable (B) -> C) -> @Sendable (Either<A, B>) -> Either<A, C> {
    return { either in
        switch either {
            case let .left(a):
                return .left(a)
            case let .right(c):
                return .right(b2c(c))
        }
    }
}
