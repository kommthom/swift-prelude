import Prelude

public struct State<S: Sendable, A: Sendable>: Sendable {
    public let run: @Sendable (S) -> (result: A, finalState: S)

    public init(run: @escaping @Sendable (S) -> (result: A, finalState: S)) {
        self.run = run
    }

    public func eval(_ state: S) -> A {
        return self.run(state).result
    }

    public func exec(_ state: S) -> S {
        return self.run(state).finalState
    }

    public func with(_ modification: @escaping @Sendable (S) -> S) -> State<S, A> {
        return State(run: self.run <<< modification)
    }
}

extension State {
    public static var get: State<S, S> {
        return .init { ($0, $0) }
    }

    public static func gets(_ f: @escaping @Sendable (S) -> A) -> State<S, A> {
        return .init { (f($0), $0) }
    }

    public static func put(_ state: S) -> State<S, Unit> {
        return .init { _ in (unit, state) }
    }

    public static func modify(_ f: @escaping @Sendable (S) -> S) -> State<S, Unit> {
        return .init { (unit, f($0)) }
    }
}

// MARK: - Functor

extension State {
    public func map<B: Sendable>(_ a2b: @escaping @Sendable (A) -> B) -> State<S, B> {
        return State<S, B> { state in
            let (result, finalState) = self.run(state)
            return (
                a2b(
                    result
                ),
                finalState
            )
        }
    }

    public static func <¢> <B: Sendable>(a2b: @escaping @Sendable (A) -> B, sa: State<S, A>) -> State<S, B> {
        return sa.map(a2b)
    }
}

// MARK: - Apply

extension State {
    public func apply<B: Sendable>(_ sa2b: State<S, @Sendable (A) -> B>) -> State<S, B> {
        return sa2b.flatMap { a2b in self.map(a2b) }
    }

    public static func <*> <B: Sendable>(sa2b: State<S, @Sendable (A) -> B>, sa: State) -> State<S, B> {
        return sa.apply(sa2b)
    }
}

// MARK: - Applicative

public func pure<S, A: Sendable>(_ a: A) -> State<S, A> {
    return .init { (a, $0) }
}

// MARK: - Bind/Monad

extension State {
    public func flatMap<B: Sendable>(_ a2sb: @escaping @Sendable (A) -> State<S, B>) -> State<S, B> {
        return State<S, B> { state in
            let (result, nextState) = self.run(state)
            return a2sb(result).run(nextState)
        }
  }
}
