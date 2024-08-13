public func optional<A: Sendable, B: Sendable>(_ default: @autoclosure @escaping @Sendable () -> B) -> @Sendable (@escaping @Sendable (A) -> B) -> @Sendable (A?) -> B {
    return { a2b in { a in
            a.map(a2b) ?? `default`()
    } }
}

public func coalesce<A: Sendable>(with default: @autoclosure @escaping @Sendable () -> A) -> @Sendable (A?) -> A {
    return { a in  a ?? `default`() }
}


extension Optional {
    public func `do`(_ f: @Sendable (Wrapped) -> Void) {
        if let x = self { f(x) }
    }
}

// MARK: - Functor

extension Optional {
    public static func <¢> <A: Sendable>(f: @Sendable (Wrapped) -> A, x: Optional) -> A? {
        return x.map(f)
    }
}

public func map<A: Sendable, B: Sendable>(_ a2b: @escaping @Sendable (A) -> B) -> @Sendable (A?) -> B? {
    return { a in
        a2b <¢> a
    }
}

// MARK: - Apply

extension Optional {
    public func apply<A: Sendable>(_ f: (@Sendable (Wrapped) -> A)?) -> A? {
        // return f.flatMap(self.map) // https://bugs.swift.org/browse/SR-5422
        guard let f = f, let a = self else { return nil }
        return f(a)
    }

    public static func <*> <A: Sendable>(f: (@Sendable (Wrapped) -> A)?, x: Optional) -> A? {
        return x.apply(f)
    }
}

public func apply<A: Sendable, B: Sendable>(_ a2b: (@Sendable (A) -> B)?) -> @Sendable (A?) -> B? {
    return { a in
        a2b <*> a
    }
}

// MARK: - Applicative

public func pure<A: Sendable>(_ a: A) -> A? {
    return .some(a)
}

// MARK: - Traversable

public func traverse<S: Sendable, A: Sendable, B: Sendable>(_ f: @escaping @Sendable (A) -> B?) -> @Sendable (S) -> [B]? where S: Sequence, S.Element == A {
    return { xs in
        var ys: [B] = []
        for x in xs {
            guard let y = f(x) else { return nil }
            ys.append(y)
        }
        return ys
    }
}

public func sequence<A: Sendable>(_ xs: [A?]) -> [A]? {
    return xs |> traverse( { a in id(a) } )
}

// MARK: - Bind/Monad

public func flatMap<A: Sendable, B: Sendable>(_ a2b: @escaping @Sendable (A) -> B?) -> @Sendable (A?) -> B? {
    return { a in
        a.flatMap(a2b)
    }
}

public func >=> <A: Sendable, B: Sendable, C: Sendable>(lhs: @escaping @Sendable (A) -> B?, rhs: @escaping @Sendable (B) -> C?) -> @Sendable (A) -> C? {
    return lhs >>> flatMap(rhs)
}

// MARK: - Semigroup

extension Optional: Semigroup where Wrapped: Semigroup {
    public static func <> (lhs: Optional, rhs: Optional) -> Optional {
        return switch (lhs, rhs) {
            case (.none, _): rhs
            case (_, .none): lhs
            case let (.some(l), .some(r)): .some(l <> r)
        }
    }
}

// MARK: - Monoid

extension Optional: Monoid where Wrapped: Semigroup {
    public static var empty: Optional {
        return .none
    }
}

// MARK: - Foldable/Sequence

extension Optional {
    public func foldMap<M: Monoid>(_ f: @escaping @Sendable (Wrapped) -> M) -> M {
        return self.map(f) ?? M.empty
    }
}

public func foldMap<A: Sendable, M: Monoid>(_ f: @escaping @Sendable (A) -> M) -> @Sendable (A?) -> M {
    return { xs in
        xs.foldMap(f)
    }
}
