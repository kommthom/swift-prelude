import Prelude

public enum Validation<E: Sendable, A: Sendable>: Sendable {
    case valid(A)
    case invalid(E)
}

extension Validation {
    public func validate<B: Sendable>(_ e2b: @Sendable (E) -> B, _ a2b: @Sendable (A) -> B) -> B {
        switch self {
            case let .valid(a):
                return a2b(a)
            case let .invalid(e):
                return e2b(e)
        }
    }

    public var isValid: Bool {
        return validate(const(false), const(true))
    }
}

public func validate<A: Sendable, B: Sendable, C: Sendable>(_ a2c: @escaping @Sendable (A) -> C) -> (@escaping @Sendable (B) -> C) -> @Sendable (Validation<A, B>) -> C {
    return { b2c in
        { ab in
            ab.validate(a2c, b2c)
        }
    }
}

// MARK: - Functor

extension Validation {
    public func map<B: Sendable>(_ a2b: @Sendable (A) -> B) -> Validation<E, B> {
        switch self {
            case let .valid(a):
                return .valid(a2b(a))
            case let .invalid(e):
                return .invalid(e)
        }
    }

    public func map<B: Sendable>(_ a2b: @Sendable (A)async  -> B) async -> Validation<E, B> {
        return switch self {
            case let .valid(a):
                .valid(await a2b(a))
            case let .invalid(e):
                .invalid(e)
        }
    }
    
    public static func <¢> <B: Sendable>(a2b: @Sendable (A) -> B, a: Validation) -> Validation<E, B> {
        return a.map(a2b)
    }
}

public func map<A: Sendable, B: Sendable, C: Sendable>(_ b2c: @escaping @Sendable (B) -> C) -> @Sendable (Validation<A, B>) -> Validation<A, C> {
    return { ab in
      b2c <¢> ab
    }
}

// MARK: - Bifunctor

extension Validation {
    public func bimap<B: Sendable, C: Sendable>(_ e2b: @Sendable (E) -> B, _ a2c: @Sendable (A) -> C) -> Validation<B, C> {
        switch self {
            case let .valid(a):
                return .valid(a2c(a))
            case let .invalid(e):
                return .invalid(e2b(e))
        }
    }
}

public func bimap<A: Sendable, B: Sendable, C: Sendable, D: Sendable>(_ a2c: @escaping @Sendable (A) -> C) -> (@escaping @Sendable (B) -> D) -> @Sendable (Validation<A, B>) -> Validation<C, D> {
    return { b2d in
        { ab in
            ab.bimap(a2c, b2d)
        }
    }
}

// MARK: - Apply

extension Validation where E: Semigroup {
    public func apply<B: Sendable>(_ a2b: Validation<E, @Sendable (A) -> B>) -> Validation<E, B> {
        switch (a2b, self) {
            case let (.valid(f), _):
                return self.map(f)
            case let (.invalid(e), .valid):
                return .invalid(e)
            case let (.invalid(e1), .invalid(e2)):
                return .invalid(e1 <> e2)
        }
    }

    public static func <*> <B: Sendable>(a2b: Validation<E, @Sendable (A) -> B>, a: Validation) -> Validation<E, B> {
        return a.apply(a2b)
    }
}

public func apply<A: Semigroup, B: Sendable, C: Sendable>(_ b2c: Validation<A, @Sendable (B) -> C>) -> @Sendable (Validation<A, B>) -> Validation<A, C> {
    return { ab in
        b2c
        <*>
        ab
    }
}

// MARK: - Applicative

public func pure<E: Sendable, A: Sendable>(_ a: A) -> Validation<E, A> {
    return .valid(a)
}

// MARK: - Eq/Equatable

extension Validation: Equatable where E: Equatable, A: Equatable {
    public static func == (lhs: Validation, rhs: Validation) -> Bool {
        switch (lhs, rhs) {
            case let (.invalid(e1), .invalid(e2)):
                return e1 == e2
            case let (.valid(a1), .valid(a2)):
                return a1 == a2
            default:
                return false
        }
    }
}

// MARK: - Ord/Comparable

extension Validation: Comparable where E: Comparable, A: Comparable {
    public static func < (lhs: Validation, rhs: Validation) -> Bool {
        switch (lhs, rhs) {
            case let (.invalid(e1), .invalid(e2)):
                return e1 < e2
            case let (.valid(a1), .valid(a2)):
                return a1 < a2
            case (.invalid, .valid):
                return true
            case (.valid, .invalid):
                return false
        }
    }
}

// MARK: - Semigroup

extension Validation: Semigroup where E: Semigroup, A: Semigroup {
    public static func <> (lhs: Validation, rhs: Validation) -> Validation {
        return curry(
            { $0 <> $1 }
        )
        <¢>
        lhs
        <*>
        rhs
    }
}

extension Validation where E: AsyncSemigroup {
    public func apply<B: Sendable>(_ a2b: Validation<E, @Sendable (A) async -> B>) async -> Validation<E, B> {
        return switch (a2b, self) {
            case let (.valid(f), _):
                await self.map(f)
            case let (.invalid(e), .valid):
                .invalid(e)
            case let (.invalid(e1), .invalid(e2)):
                await .invalid(e1 <> e2)
        }
    }

    public static func <*> <B: Sendable>(a2b: Validation<E, @Sendable (A) async -> B>, a: Validation) async -> Validation<E, B> {
        return await a.apply(a2b)
    }
}
