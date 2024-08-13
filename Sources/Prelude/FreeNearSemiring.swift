public struct FreeNearSemiring<A: Sendable>: NearSemiring, Sendable {
    public let elements: [[A]]

    public init(_ elements: [[A]]) {
        self.elements = elements
    }

    public static func + (lhs: FreeNearSemiring<A>, rhs: FreeNearSemiring<A>) -> FreeNearSemiring<A> {
        return .init(
            lhs.elements
            +  // <> if Semigroup
            rhs.elements)
    }

    public static func * (xss: FreeNearSemiring<A>, yss: FreeNearSemiring<A>) -> FreeNearSemiring<A> {
        return .init(
            xss.elements
                .flatMap { xs in
                    yss.elements
                        .map { ys in
                            xs
                            + // <> if Semigroup
                            ys
                        }
                }
        )
    }
    
    public static var zero: FreeNearSemiring<A> { .init([]) }
    
    public static var one: FreeNearSemiring<A> { .init([[]]) }
}

// MARK: - Functor

public func map<A: Sendable, B: Sendable>(_ f: @escaping @Sendable (A) -> B) -> @Sendable (FreeNearSemiring<A>) -> FreeNearSemiring<B> {
    return { s in
          .init(s.elements.map { $0.map(f) })
    }
}

// MARK: - Apply

public func apply<A: Sendable, B: Sendable>(_ fss: FreeNearSemiring<@Sendable(A) -> B>) -> @Sendable (FreeNearSemiring<A>) -> FreeNearSemiring<B> {
    return { (xss: FreeNearSemiring<A>) -> FreeNearSemiring<B> in
        .init(
            fss.elements.flatMap { fs in
                xss.elements.map { xs in
                    fs <*> xs
                }
            }
        )
    }
}

// MARK: - Applicative

public func pure<A: Sendable>(_ a: A) -> FreeNearSemiring<A> {
    return .init([[a]])
}

// MARK: - Equatable

extension FreeNearSemiring: Equatable where A: Equatable {
    public static func == (lhs: FreeNearSemiring, rhs: FreeNearSemiring) -> Bool {
        return lhs.elements == rhs.elements
    }
}
