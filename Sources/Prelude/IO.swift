import Dependencies
import Dispatch
import Foundation

public struct IO<A: Sendable>: Sendable {
    private let compute: @Sendable () async -> A

    public init(_ compute: @escaping @Sendable () -> A) {
        self.init({ () async -> A in compute() })
    }

    public init(_ compute: @escaping @Sendable () async -> A) {
        self.compute = withEscapedDependencies { continuation in
            return {
                await continuation.yield { await compute() }
            }
        }
    }

    public func performAsync() async -> A {
        await self.compute()
    }
}

extension IO {
    public static func wrap<I: Sendable>(_ f: @escaping @Sendable (I) -> A) -> @Sendable (I) -> IO<A> {
        return { input in
                .init { f(input) }
        }
    }
}

extension IO {
    public init(_ callback: @escaping @Sendable (@escaping @Sendable (A) -> ()) -> ()) {
        self.init {
            await withCheckedContinuation { continuation in
                callback { a in
                    continuation.resume(returning: a)
                }
            }
        }
    }

    public func delay(_ interval: DispatchTimeInterval) -> IO {
        return .init {
            switch interval {
                case let .microseconds(n):
                    try? await Task.sleep(nanoseconds: UInt64(n) * 1_000)
                case let .milliseconds(n):
                    try? await Task.sleep(nanoseconds: UInt64(n) * 1_000_000)
                case .never:
                    let never = AsyncStream<Void> { _ in }
                    for await _ in never {}
                case let .nanoseconds(n):
                    try? await Task.sleep(nanoseconds: UInt64(n))
                case let .seconds(n):
                    try? await Task.sleep(nanoseconds: UInt64(n) * 1_000_000_000)
                    @unknown default:
                    let never = AsyncStream<Void> { _ in }
                    for await _ in never {}
                }
                return await self.performAsync()
        }
  }

  public func delay(_ interval: TimeInterval) -> IO {
        return .init {
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            return await self.performAsync()
        }
    }
}

public func delay<A: Sendable>(_ interval: DispatchTimeInterval) -> @Sendable (IO<A>) -> IO<A> {
    return { $0.delay(interval) }
}

public func delay<A: Sendable>(_ interval: TimeInterval) -> @Sendable (IO<A>) -> IO<A> {
    return { $0.delay(interval) }
}

extension IO {
    public var parallel: Parallel<A> {
        Parallel {
            await self.performAsync()
        }
    }
}

// MARK: - Functor

extension IO {
    public func map<B: Sendable>(_ f: @escaping @Sendable (A) -> B) -> IO<B> {
        return IO<B> {
            await self.performAsync() |> f
        }
    }

    public static func <¢> <B: Sendable>(f: @escaping @Sendable (A) -> B, x: IO<A>) -> IO<B> {
        return x.map(f)
    }
}

public func map<A: Sendable, B: Sendable>(_ f: @escaping @Sendable (A) -> B) -> @Sendable (IO<A>) -> IO<B> {
    return { f <¢> $0 }
}

// MARK: - Apply

extension IO {
    public func apply<B: Sendable>(_ f: IO<@Sendable (A) -> B>) -> IO<B> {
        return IO<B> {
            await f.performAsync() <| self.performAsync()
        }
    }

    public static func <*> <B: Sendable>(f: IO<@Sendable (A) -> B>, x: IO<A>) -> IO<B> {
        return x.apply(f)
    }
}

public func apply<A: Sendable, B: Sendable>(_ f: IO<@Sendable (A) -> B>) -> @Sendable (IO<A>) -> IO<B> {
    return { f <*> $0 }
}

// MARK: - Applicative

public func pure<A: Sendable>(_ a: A) -> IO<A> {
    return IO { a }
}

// MARK: - Traversable

public func traverse<S: Sendable, A: Sendable, B: Sendable>(_ f: @escaping @Sendable (A) -> IO<B>) -> @Sendable (S) -> IO<[B]> where S: Sequence, S.Element == A {
    return { (xs: S) -> IO<[B]> in
        IO<[B]> { () async -> [B] in
            var ys: [B] = []
            ys.reserveCapacity(xs.underestimatedCount)
            for x in xs {
                await ys.append(f(x).performAsync())
            }
            return ys
        }
    }
}

public func sequence<S: Sendable, A: Sendable>(_ xs: S) -> IO<[A]> where S: Sequence, S.Element == IO<A> {
    return xs
        |>
        traverse( { id($0) } )
}

// MARK: - Bind/Monad

extension IO {
    public func flatMap<B: Sendable>(_ f: @escaping @Sendable (A) -> IO<B>) -> IO<B> {
        return IO<B> {
            await f(self.performAsync()).performAsync()
        }
    }
}

public func flatMap<A: Sendable, B: Sendable>(_ f: @escaping @Sendable (A) -> IO<B>) -> @Sendable (IO<A>) -> IO<B> {
    return { $0.flatMap(f) }
}

public func >=> <A: Sendable, B: Sendable, C: Sendable>(lhs: @escaping @Sendable (A) -> IO<B>, rhs: @escaping @Sendable (B) -> IO<C>) -> @Sendable (A) -> IO<C> {
    return lhs >>> flatMap(rhs)
}

// MARK: - Semigroup

extension IO: Semigroup where A: Semigroup {
    public static func <> (lhs: IO, rhs: IO) -> IO {
        return curry(
            { $0 <> $1 }
            )
            <¢>
            lhs
            <*>
            rhs
    }
}

// MARK: - Monoid

extension IO: Monoid where A: Monoid {
    public static var empty: IO {
        return pure(A.empty)
    }
}

@dynamicMemberLookup
fileprivate final class LockIsolated<Value>: @unchecked Sendable {
    private var _value: Value
    private let lock = NSRecursiveLock()

    init(_ value: @autoclosure @Sendable () throws -> Value) rethrows {
        self._value = try value()
    }

    subscript<Subject: Sendable>(dynamicMember keyPath: KeyPath<Value, Subject>) -> Subject {
        self.lock.sync {
            self._value[keyPath: keyPath]
        }
    }

    func withValue<T: Sendable>(_ operation: (inout Value) throws -> T) rethrows -> T {
        try self.lock.sync {
            var value = self._value
            defer { self._value = value }
            return try operation(&value)
        }
    }

    func setValue(_ newValue: @autoclosure @Sendable () throws -> Value) rethrows {
        try self.lock.sync {
            self._value = try newValue()
        }
    }
}

extension LockIsolated where Value: Sendable {
    /// The lock-isolated value.
    var value: Value {
        self.lock.sync {
            self._value
        }
    }
}

extension LockIsolated: Equatable where Value: Equatable {
  static func == (lhs: LockIsolated, rhs: LockIsolated) -> Bool {
    lhs.withValue { lhsValue in rhs.withValue { rhsValue in lhsValue == rhsValue } }
  }
}

extension LockIsolated: Hashable where Value: Hashable {
  func hash(into hasher: inout Hasher) {
    self.withValue { hasher.combine($0) }
  }
}

extension NSRecursiveLock {
    @inlinable @discardableResult
    @_spi(Internals) public func sync<R: Sendable>(work: () throws -> R) rethrows -> R {
        self.lock()
        defer { self.unlock() }
        return try work()
    }
}
