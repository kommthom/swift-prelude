import Prelude

infix operator .^: infixl8 // viewOn

/// A getter lens.
public typealias Getter<S: Sendable, T: Sendable, A: Sendable, B: Sendable> = Fold<A, S, T, A, B>

// TODO: Add `first` to `Forget`.
//public func lens<S, T, A, B>(_ to: @escaping (S) -> (A, (B) -> T)) -> Getter<S, T, A, B> {
//  return { pab in to >>> first(pab) >>> { bf in bf.1(bf.0) } }
//}
//
//public func lens<S, T, A, B>(_ get: @escaping (S) -> A, _ set: @escaping (S, B) -> T) -> Getter<S, T, A, B> {
//  return lens({ s in (get(s), { b in set(s, b) }) })
//}

/// Composes two getters together.
///
///     (1, (2, 3)) .^ second <<< first // 2
///
/// - Parameters:
///   - lhs: The root getter.
///   - rhs: A getter with a source matching the target of the left-hand getter.
/// - Returns: A new getter from the source of the left-hand getter to the target of the right-hand getter.
public func <<< <A: Sendable, B: Sendable, S: Sendable, T: Sendable, U: Sendable, V: Sendable>(_ lhs: @escaping Getter<U, V, S, T>, _ rhs: @escaping Getter<S, T, A, B>) -> Getter<U, V, A, B> {
    return { forget in
        .init(
            forget.unwrap
            <<<
            rhs(
                Forget(
                    { id($0) }
                )
            ).unwrap
            <<<
            lhs(
                Forget(
                    { id($0) }
                )
            ).unwrap
        )
    }
}

/// Produces a getter function from a getter lens.
///
/// - Parameter getter: A getter.
/// - Returns: A function from the source of a getter to its focus.
public func view<S: Sendable, T: Sendable, A: Sendable, B: Sendable>(_ getter: @escaping Getter<S, T, A, B>) -> @Sendable (S) -> A {
    return getter(
        .init(
            { id($0) }
        )
    ).unwrap
}

/// An operator version of `view`, flipped.
///
///     (1, 2) .^ second // 2
///
/// - Parameters:
///   - source: A source value.
///   - getter: A getter from a source to its focus.
/// - Returns: The focus of the source.
public func .^ <S: Sendable, T: Sendable, A: Sendable, B: Sendable>(source: S, getter: @escaping Getter<S, T, A, B>) -> A {
    return source 
        |>
        view(
            getter
        )
}

/// Converts a function into a getter.
///
/// - Parameter f: A function from a source value to its focus.
/// - Returns: A getter.
public func to<R: Sendable, S: Sendable, T: Sendable, A: Sendable, B: Sendable>(_ f: @escaping @Sendable (S) -> A) -> Fold<R, S, T, A, B> {
    return { p in
        .init(
            p.unwrap
            <<<
            f
        )
    }
}
