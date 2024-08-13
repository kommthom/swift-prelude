public struct Endo<A: Sendable> {
    public let call: @Sendable (A) -> A

    public init(_ call: @escaping @Sendable (A) -> A) {
        self.call = call
    }
}

extension Endo: Semigroup {
    public static func <> (lhs: Endo<A>, rhs: Endo<A>) -> Endo<A> {
        return .init(lhs.call >>> rhs.call)
    }
}

extension Endo: Monoid {
    public static var empty: Endo<A> {
        return .init( { id($0) } )
    }
}

extension Endo {
    func imap<B>(_ f: @escaping @Sendable (A) -> B, _ g: @escaping @Sendable (B) -> A) -> Endo<B> {
        return .init(f <<< self.call <<< g)
    }
}
