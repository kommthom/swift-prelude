import Dispatch
import Foundation
import Prelude

/// A monad transformer (like `ExceptT`) for `IO` and `Either`.
public struct EitherIO<E: Sendable, A: Sendable>: Sendable {
    public let run: IO<Either<E, A>>

    public init(run: IO<Either<E, A>>) {
        self.run = run
    }

    public func `catch`(_ f: @escaping @Sendable (E) -> EitherIO) -> EitherIO {
        return catchE(self, f)
    }

    public func mapExcept<F, B>(_ f: @escaping @Sendable (Either<E, A>) -> Either<F, B>) -> EitherIO<F, B> {
        return .init(
            run: self.run.map(f)
        )
    }

    public func withExcept<F>(_ f: @escaping @Sendable (E) -> F) -> EitherIO<F, A> {
        return self
            .bimap(
                f,
                { id($0) }
            )
    }
}

public func lift<E: Sendable, A: Sendable>(_ x: Either<E, A>) -> EitherIO<E, A> {
    return { EitherIO.init(run: $0) }
        <<<
        { pure($0) }
        <|
        x
}

public func lift<E: Sendable, A: Sendable>(_ x: IO<A>) -> EitherIO<E, A> {
    return { EitherIO.init(run: $0) }
        <<<
        map(
            { Either.right($0) }
        )
        <|
        x
}

public func throwE<E: Sendable, A: Sendable>(_ x: E) -> EitherIO<E, A> {
    return lift(.left(x))
}

public func catchE<E: Sendable, A: Sendable>(_ x: EitherIO<E, A>, _ f: @escaping @Sendable (E) -> EitherIO<E, A>) -> EitherIO<E, A> {
    return .init(
        run: x
            .run
            .flatMap(
                either(
                    ^\.run
                      <<<
                      f,
                      { pure($0) }
                      <<<
                      { Either.right($0) }
                )
            )
    )
}

public func mapExcept<E: Sendable, F: Sendable, A: Sendable, B: Sendable>(_ f: @escaping @Sendable (Either<E, A>) -> Either<F, B>) -> @Sendable (EitherIO<E, A>) -> EitherIO<F, B> {
    return { $0.mapExcept(f) }
}

public func withExcept<E: Sendable, F: Sendable, A: Sendable>(_ f: @escaping @Sendable (E) -> F) -> @Sendable (EitherIO<E, A>) -> EitherIO<F, A> {
    return { $0.withExcept(f) }
}

extension EitherIO where E == Error {
    public static func wrap(_ f: @escaping @Sendable () throws -> A) -> EitherIO {
        return { EitherIO.init(run: $0) }
            <<<
            { pure($0) }
            <|
            Either.wrap(
                f
            )
    }

    public init(_ f: @escaping @Sendable () async throws -> A) {
        self.init(
            run: IO {
                do {
                    return try await .right(f())
                } catch {
                    return .left(error)
                }
            }
        )
  }

  public func performAsync() async throws -> A {
      try await self.run.performAsync().unwrap()
  }
}

extension EitherIO where E: Error {
    public func performAsync() async throws -> A {
        try await self.run.performAsync().unwrap()
    }
}

extension EitherIO {
    public func retry(maxRetries: Int) -> EitherIO {
        return retry(maxRetries: maxRetries, backoff: const(.seconds(0)))
    }

    public func retry(maxRetries: Int, backoff: @escaping @Sendable (Int) -> DispatchTimeInterval) -> EitherIO {
        return self.retry(maxRetries: maxRetries, attempts: 1, backoff: backoff)
    }

    private func retry(maxRetries: Int, attempts: Int, backoff: @escaping @Sendable (Int) -> DispatchTimeInterval) -> EitherIO {
        guard attempts < maxRetries else { return self }
        return self <|> .init(run:
                                self
                                    .retry(maxRetries: maxRetries, attempts: attempts + 1, backoff: backoff)
                                    .run
                                    .delay(backoff(attempts))
                            )
    }

    public func delay(_ interval: DispatchTimeInterval) -> EitherIO {
        return .init(run: self.run.delay(interval))
    }

    public func delay(_ interval: TimeInterval) -> EitherIO {
        return .init(run: self.run.delay(interval))
    }
}

// MARK: - Functor

extension EitherIO {
    public func map<B: Sendable>(_ f: @escaping @Sendable (A) -> B) -> EitherIO<E, B> {
        return .init(
            run: self.run.map { $0.map(f) }
        )
    }

    public static func <¢> <B: Sendable>(f: @escaping @Sendable (A) -> B, x: EitherIO) -> EitherIO<E, B> {
        return x.map(f)
    }
}

public func map<E: Sendable, A: Sendable, B: Sendable>(_ f: @escaping @Sendable (A) -> B) -> @Sendable (EitherIO<E, A>) -> EitherIO<E, B> {
    return { f <¢> $0 }
}

// MARK: - Bifunctor

extension EitherIO {
    public func bimap<F: Sendable, B: Sendable>(_ f: @escaping @Sendable (E) -> F, _ g: @escaping @Sendable (A) -> B) -> EitherIO<F, B> {
        return .init(run: self.run.map { $0.bimap(f, g) })
    }
}

public func bimap<E: Sendable, F: Sendable, A: Sendable, B: Sendable>(_ f: @escaping @Sendable (E) -> F, _ g: @escaping @Sendable (A) -> B) -> @Sendable (EitherIO<E, A>) -> EitherIO<F, B> {
        return { $0.bimap(f, g) }
}

// MARK: - Apply

extension EitherIO {
    public func apply<B: Sendable>(_ f: EitherIO<E, @Sendable (A) -> B>) -> EitherIO<E, B> {
        return .init(run:
                     curry(
                        { $0 <*> $1 }
                     )
                     <¢>
                     f.run
                     <*>
                     self.run
        )
    }

    public static func <*> <B: Sendable>(f: EitherIO<E, @Sendable (A) -> B>, x: EitherIO) -> EitherIO<E, B> {
        return x
            .apply(f)
    }
}

public func apply<E: Sendable, A: Sendable, B: Sendable>(_ f: EitherIO<E, @Sendable (A) -> B>) -> @Sendable (EitherIO<E, A>) -> EitherIO<E, B> {
    return {
        f
        <*>
        $0
    }
}

// MARK: - Applicative

public func pure<E: Sendable, A: Sendable>(_ x: (A)) -> EitherIO<E, A> {
    return { EitherIO.init(run: $0) }
        <<<
        { pure($0) }
        <<<
        { pure($0) }
        <|
        x
}

// MARK: - Traversable

// Sequences an array of `EitherIO`'s by first sequencing the `IO` values, and then sequencing the `Either`
// values.
public func sequence<S: Sendable, E: Sendable, A: Sendable>(_ xs: S) -> EitherIO<E, [A]> where S: Sequence, S.Element == EitherIO<E, A> {
    return EitherIO(run:
        sequence(
            xs.map(
                ^\.run
            )
        ).map( { sequence($0) } )
    )
}

// MARK: - Alt

extension EitherIO: Alt {
    public static func <|> (lhs: EitherIO, rhs: @autoclosure @escaping @Sendable () -> EitherIO) -> EitherIO {
        return .init(
            run: IO {
                switch await lhs.run.performAsync() {
                    case .left:
                        return await rhs()
                        .run
                        .performAsync()
                    case let .right(a):
                        return .right(a)
                }
            }
        )
    }
}

// MARK: - Bind/Monad

extension EitherIO {
    public func flatMap<B: Sendable>(_ f: @escaping @Sendable (A) -> EitherIO<E, B>) -> EitherIO<E, B> {
        return .init(
            run: self
                .run
                .flatMap(
                    either(
                        { pure($0) }
                        <<<
                        { Either.left($0) },
                        ^\.run
                        <<<
                        f
                    )
                )
        )
    }
}

public func flatMap<E: Sendable, A: Sendable, B: Sendable>(_ f: @escaping @Sendable (A) -> EitherIO<E, B>) -> @Sendable (EitherIO<E, A>) -> EitherIO<E, B> {
    return { $0.flatMap(f) }
}

public func >=> <E: Sendable, A: Sendable, B: Sendable, C: Sendable>(f: @escaping @Sendable (A) -> EitherIO<E, B>, g: @escaping @Sendable (B) -> EitherIO<E, C>) -> @Sendable (A) -> EitherIO<E, C> {
    return f >>> flatMap(g)
}
