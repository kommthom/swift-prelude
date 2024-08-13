
public struct Func<A: Sendable, B: Sendable>: Sendable {
    public let call: @Sendable (A) -> B

    public init(_ call: @escaping @Sendable (A) -> B) {
        self.call = call
    }
}

extension Func /* : Semigroupoid */ {
    public static func >>> <C: Sendable>(f: Func, g: Func<B, C>) -> Func<A, C> {
        return .init(f.call >>> g.call)
    }

    public static func <<< <C: Sendable>(f: Func<B, C>, g: Func) -> Func<A, C> {
        return .init(f.call <<< g.call)
    }
}

extension Func /* : Functor */ {
    public func map<C: Sendable>(_ f: @escaping @Sendable (B) -> C) -> Func<A, C> {
        return .init(self.call >>> f)
    }

    public static func <¢> <C: Sendable>(f: @escaping @Sendable (B) -> C, g: Func) -> Func<A, C> {
        return g.map(f)
    }
}

public func map<A: Sendable, B: Sendable, C: Sendable>(_ f: @escaping @Sendable (B) -> C) -> @Sendable (Func<A, B>) -> Func<A, C> {
    return { $0.map(f) }
}

extension Func /* : Contravariant */ {
    public func contramap<Z: Sendable>(_ f: @escaping @Sendable (Z) -> A) -> Func<Z, B> {
        return .init(f >>> self.call)
    }

    public static func >¢< <C: Sendable, D: Sendable, E: Sendable>(f: @escaping @Sendable (D) -> C, g: Func<C, E>) -> Func<D, E> {
        return g
            .contramap(
                f
            )
    }
}

public func contramap<A: Sendable, B: Sendable, C: Sendable>(_ f: @escaping @Sendable (B) -> A) -> @Sendable (Func<A, C>) -> Func<B, C> {
    return { $0.contramap(f) }
}

extension Func /* : Profunctor */ {
    public func dimap<Z, C: Sendable>(_ f: @escaping @Sendable (Z) -> A, _ g: @escaping @Sendable (B) -> C) -> Func<Z, C> {
        return .init(f >>> self.call >>> g)
    }
}

public func dimap<A: Sendable, B: Sendable, C: Sendable, D: Sendable>(_ f: @escaping @Sendable (A) -> B, _ g: @escaping @Sendable (C) -> D) -> @Sendable (Func<B, C>) -> Func<A, D> {
    return { $0.dimap(f, g) }
}

extension Func /* : Apply */ {
    public func apply<C: Sendable>(_ f: Func<A, Func<B, C>>) -> Func<A, C> {
        return .init { a in
            f
            .call(a)
            .call(
                self
                .call(
                    a
                )
            )
        }
    }

    public static func <*> <C: Sendable>(f: Func<A, Func<B, C>>, x: Func) -> Func<A, C> {
        return x.apply(f)
    }
}

public func apply<A: Sendable, B: Sendable, C: Sendable>(_ f: Func<A, Func<B, C>>) -> @Sendable (Func<A, B>) -> Func<A, C> {
    return { $0.apply(f) }
}

// MARK: Applicative
public func pure<A: Sendable, B: Sendable>(_ b: B) -> Func<A, B> {
    return .init(const(b))
}

extension Func /* : Monad */ {
    public func flatMap<C: Sendable>(_ f: @escaping @Sendable (B) -> Func<A, C>) -> Func<A, C> {
        return .init {
            f(
                self
                .call($0)
            )
            .call($0)
        }
    }
}

public func flatMap<A: Sendable, B: Sendable, C: Sendable>(_ f: @escaping @Sendable (B) -> Func<A, C>) -> @Sendable (Func<A, B>) -> Func<A, C> {
    return { $0.flatMap(f) }
}

extension Func: Semigroup where B: Semigroup {
    public static func <> (f: Func, g: Func) -> Func {
        return .init { f.call($0) <> g.call($0) }
    }
}

extension Func: Monoid where B: Monoid {
    public static var empty: Func {
        return .init(const(B.empty))
    }
}

extension Func: NearSemiring where B: NearSemiring {
    public static func + (f: Func, g: Func) -> Func {
        return .init {
            f.call($0)
            +
            g.call($0)
        }
    }

    public static func * (f: Func, g: Func) -> Func {
        return .init {
            f.call($0)
            *
            g.call($0)
        }
    }

    public static var zero: Func {
        return .init(const(B.zero))
    }
}

extension Func: Semiring where B: Semiring {
    public static var one: Func {
        return .init(const(B.one))
    }
}
