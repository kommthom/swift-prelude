import Prelude

public enum Either<L: Sendable, R: Sendable>: Sendable {
    case left(L)
    case right(R)
}

extension Either {
    public func either<A: Sendable>(_ l2a: @Sendable (L) throws -> A, _ r2a: @Sendable (R) -> A) rethrows -> A {
        switch self {
            case let .left(l): return try l2a(l)
            case let .right(r): return r2a(r)
        }
    }

    public var left: L? {
        return switch self {
            case let .left(l): Optional.some(l)
            case let .right(r): const(.none)(r)
        }
    }

    public var right: R? {
        return switch self {
            case let .left(l): const(.none)(l)
            case let .right(r): Optional.some(r)
        }
    }

  public var isLeft: Bool {
      return either(const(true), const(false))
  }

  public var isRight: Bool {
      return either(const(false), const(true))
  }
}

extension Optional: Sendable where Wrapped == Sendable {}

public func either<A: Sendable, B: Sendable, C: Sendable>(_ a2c: @escaping @Sendable (A) -> C, _ b2c: @escaping @Sendable (B) -> C) -> @Sendable (Either<A, B>) -> C {
    return { ab in
        ab.either(a2c, b2c)
    }
}

public func lefts<S: Sequence & Sendable, L: Sendable, R: Sendable>(_ xs: S) -> [L] where S.Element == Either<L, R> {
    return xs |> mapOptional { $0.left }
}

public func rights<S: Sequence & Sendable, L: Sendable, R: Sendable>(_ xs: S) -> [R] where S.Element == Either<L, R> {
    return xs |> mapOptional { $0.right }
}

public func note<L: Sendable, R: Sendable>(_ default: L) -> @Sendable (R?) -> Either<L, R> {
    return { a in
        guard let r = a else { return Either.left(`default`) }
        return Either.right(r)
    }
}

public func hush<L: Sendable, R: Sendable>(_ lr: Either<L, R>) -> R? {
    return switch lr {
        case let .left(l): const(.none)(l)
        case let .right(r): R?.some(r)
    }
}

extension Either where L == Error {
    public static func wrap<A: Sendable>(_ f: @escaping @Sendable (A) throws -> R) -> @Sendable (A) -> Either {
        return { a in
            do {
                return .right(try f(a))
            } catch let error {
                return .left(error)
            }
        }
    }

    public static func wrap(_ f: @escaping @Sendable () throws -> R) -> Either {
        do {
            return .right(try f())
        } catch let error {
            return .left(error)
        }
    }

    public func unwrap() throws -> R {
        return switch self {
            case let .left(l): try { throw $0 }(l)
            case let .right(r): id(r)
        }
    }
}

extension Either where L: Error & Sendable {
    public func unwrap() throws -> R {
        return switch self {
            case let .left(l): try { throw $0 }(l)
            case let .right(r): id(r)
        }
    }
}

public func unwrap<R: Sendable>(_ either: Either<Error, R>) throws -> R {
    return try either.unwrap()
}

public func unwrap<L: Error & Sendable, R: Sendable>(_ either: Either<L, R>) throws -> R {
    return try either.unwrap()
}

// MARK: - Functor

extension Either {
    public func map<A: Sendable>(_ r2a: @Sendable (R) -> A) -> Either<L, A> {
        switch self {
            case let .left(l):  return .left(l)
            case let .right(r): return .right(r2a(r))
        }
    }
    
    public static func <¢> <A: Sendable>(r2a: @Sendable (R) -> A, lr: Either) -> Either<L, A> {
        return lr.map(r2a)
    }
}

public func map<A: Sendable, B: Sendable, C: Sendable>(_ b2c: @escaping  @Sendable (B) -> C) -> @Sendable (Either<A, B>) -> Either<A, C> {
    return { ab in
        b2c <¢> ab
    }
}

// MARK: - Bifunctor

extension Either {
    public func bimap<A: Sendable, B: Sendable>(_ l2a: @Sendable (L) -> A, _ r2b: @Sendable (R) -> B) -> Either<A, B> {
        switch self {
            case let .left(l):
                return .left(l2a(l))
            case let .right(r):
                return .right(r2b(r))
        }
    }
}

public func bimap<A: Sendable, B: Sendable, C: Sendable, D: Sendable>(_ a2b: @escaping @Sendable (A) -> B, _ c2d: @escaping @Sendable (C) -> D) -> @Sendable (Either<A, C>) -> Either<B, D> {
    return { ac in
        ac.bimap(a2b, c2d)
    }
}

// MARK: - Apply

extension Either {
    public func apply<A: Sendable>(_ r2a: Either<L, @Sendable (R) -> A>) -> Either<L, A> {
        return r2a
            .flatMap(
                { self.map($0) }
            )
    }

    public static func <*> <A: Sendable>(r2a: Either<L, @Sendable (R) -> A>, lr: Either<L, R>) -> Either<L, A> {
        return lr.apply(r2a)
    }
}

public func apply<A: Sendable, B: Sendable, C: Sendable>(_ b2c: Either<A, @Sendable (B) -> C>) -> @Sendable (Either<A, B>) -> Either<A, C> {
    return { ab in
        b2c
        <*>
        ab
    }
}

// MARK: - Applicative

public func pure<L: Sendable, R: Sendable>(_ r: R) -> Either<L, R> {
    return .right(r)
}

// MARK: - Traversable

public func traverse<S: Sendable, E: Sendable, A: Sendable, B: Sendable>(_ f: @escaping @Sendable (A) -> Either<E, B>) -> @Sendable (S) -> Either<E, [B]> where S: Sequence, S.Element == A {
    return { xs in
        var ys: [B] = []
        for x in xs {
            let y = f(x)
            switch y {
                case let .left(e):
                    return .left(e)
                case let .right(y):
                    ys.append(y)
            }
        }
        return .right(ys)
    }
}

/// Returns first `left` value in array of `Either`'s, or an array of `right` values if there are no `left`s.
public func sequence<E: Sendable, A: Sendable>(_ xs: [Either<E, A>]) -> Either<E, [A]> {
    return xs 
        |>
        traverse(
            { id($0) }
        )
}

// MARK: - Alt

extension Either: Alt {
    public static func <|> (lhs: Either, rhs: @autoclosure @escaping @Sendable () -> Either) -> Either {
        switch lhs {
            case .left:
                return rhs()
            case .right:
                return lhs
        }
    }
}
/*
 public func <|> <L: Sendable, R: Sendable>(lhs: Either<L, R>, rhs: Either<L, R>) -> Either<L, R> {
     switch (lhs, rhs) {
         case (.left, .right): return rhs
         default: return lhs
     }
 }
*/

// MARK: - Bind/Monad

extension Either {
    public func flatMap<A: Sendable>(_ r2a: @Sendable (R) -> Either<L, A>) -> Either<L, A> {
        switch self {
            case let .left(l): return .left(l)
            case let .right(r): return r2a(r)
        }
    }
}

public func flatMap <L: Sendable, R: Sendable, A: Sendable>(_ r2a: @escaping @Sendable (R) -> Either<L, A>) -> @Sendable (Either<L, R>) -> Either<L, A> {
    return { lr in
        lr.flatMap(r2a)
    }
}

public func >=> <E: Sendable, A: Sendable, B: Sendable, C: Sendable>(f: @escaping @Sendable (A) -> Either<E, B>, g: @escaping @Sendable (B) -> Either<E, C>) -> @Sendable (A) -> Either<E, C> {
  return f >>> flatMap(g)
}

// MARK: - Eq/Equatable

extension Either: Equatable where L: Equatable, R: Equatable {
    public static func == (lhs: Either, rhs: Either) -> Bool {
        switch (lhs, rhs) {
            case let (.left(lhs), .left(rhs)):
                return lhs == rhs
            case let (.right(lhs), .right(rhs)):
                return lhs == rhs
            default:
                return false
        }
    }
}

// MARK: - Ord/Comparable

extension Either: Comparable where L: Comparable, R: Comparable {
    public static func < (lhs: Either, rhs: Either) -> Bool {
        switch (lhs, rhs) {
            case let (.left(lhs), .left(rhs)):
                return lhs < rhs
            case let (.right(lhs), .right(rhs)):
                return lhs < rhs
            case (.left, .right):
                return true
            case (.right, .left):
                return false
        }
    }
}

// MARK: - Foldable/Sequence

extension Either where R: Sequence {
    public func reduce<A: Sendable>(_ a: A, _ f: @escaping @Sendable (A, R.Element) -> A) -> A {
        return self.map(
            Prelude.reduce(f)
            <|
            a
        )
        .either(
            const(a),
            { id($0) }
        )
  }
}

public func foldMap<S: Sequence, M: Monoid, L: Sendable>(_ f: @escaping @Sendable (S.Element) -> M) -> @Sendable (Either<L, S>) -> M {
    return { xs in
        xs.reduce(.empty) { accum, x in 
            accum
            <>
            f(x) }
    }
}

// MARK: - Semigroup

extension Either: Semigroup where R: Semigroup {
    public static func <> (lhs: Either, rhs: Either) -> Either {
        return curry(
                { $0 <> $1 }
            )
            <¢>
            lhs
            <*>
            rhs
    }
}

// MARK: - NearSemiring

extension Either: NearSemiring where R: NearSemiring {
    public static func + (lhs: Either, rhs: Either) -> Either {
        return curry(
                { $0 + $1 }
            )
            <¢>
            lhs
            <*>
            rhs
    }

    public static func * (lhs: Either, rhs: Either) -> Either {
        return curry(
                { $0 * $1 }
            )
            <¢>
            lhs
            <*>
            rhs
    }

    public static var zero: Either {
        return .right(R.zero)
    }
}

// MARK: - Semiring

extension Either: Semiring where R: Semiring {
    public static var one: Either {
        return .right(R.one)
    }
}

// MARK: - Codable

extension Either: Decodable where L: Decodable, R: Decodable {
    public init(from decoder: Decoder) throws {
        do {
            self = try .right(.init(from: decoder))
        } catch {
            self = try .left(.init(from: decoder))
        }
    }
}

extension Either: Encodable where L: Encodable, R: Encodable {
    public func encode(to encoder: Encoder) throws {
        switch self {
            case let .left(l):
                try l.encode(to: encoder)
            case let .right(r):
                try r.encode(to: encoder)
        }
    }
}
