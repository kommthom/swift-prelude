import Prelude

public struct Tuple<A: Sendable, B: Sendable>: Sendable {
    public var first: A
    public var second: B
}

public typealias T2<A, Z> = Tuple<A, Z>
public typealias T3<A, B, Z> = Tuple<A, T2<B, Z>>
public typealias T4<A, B, C, Z> = Tuple<A, T3<B, C, Z>>
public typealias T5<A, B, C, D, Z> = Tuple<A, T4<B, C, D, Z>>
public typealias T6<A, B, C, D, E, Z> = Tuple<A, T5<B, C, D, E, Z>>
public typealias T7<A, B, C, D, E, F, Z> = Tuple<A, T6<B, C, D, E, F, Z>>

public typealias Tuple1<A> = T2<A, Unit>
public typealias Tuple2<A, B> = T3<A, B, Unit>
public typealias Tuple3<A, B, C> = T4<A, B, C, Unit>
public typealias Tuple4<A, B, C, D> = T5<A, B, C, D, Unit>
public typealias Tuple5<A, B, C, D, E> = T6<A, B, C, D, E, Unit>
public typealias Tuple6<A, B, C, D, E, F> = T7<A, B, C, D, E, F, Unit>

infix operator .*.: infixr6

public func .*. <A: Sendable, B: Sendable> (lhs: A, rhs: B) -> T2<A, B> {
    return .init(first: lhs, second: rhs)
}

public func get1<A: Sendable, Z: Sendable>(_ t: T2<A, Z>) -> A {
    return t.first
}
public func get2<A: Sendable, B: Sendable, Z: Sendable>(_ t: T3<A, B, Z>) -> B {
    return t.second.first
}
public func get3<A: Sendable, B: Sendable, C: Sendable, Z: Sendable>(_ t: T4<A, B, C, Z>) -> C {
    return t.second.second.first
}
public func get4<A: Sendable, B: Sendable, C: Sendable, D: Sendable, Z: Sendable>(_ t: T5<A, B, C, D, Z>) -> D {
    return t.second.second.second.first
}
public func get5<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, Z: Sendable>(_ t: T6<A, B, C, D, E, Z>) -> E {
    return t.second.second.second.second.first
}
public func get6<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, F: Sendable, Z: Sendable>(_ t: T7<A, B, C, D, E, F, Z>) -> F {
    return t.second.second.second.second.second.first
}

public func rest<A: Sendable, Z: Sendable>(_ t: T2<A, Z>) -> Z {
    return t.second
}
public func rest<A: Sendable, B: Sendable, Z: Sendable>(_ t: T3<A, B, Z>) -> Z {
    return t.second.second
}
public func rest<A: Sendable, B: Sendable, C: Sendable, Z: Sendable>(_ t: T4<A, B, C, Z>) -> Z {
    return t.second.second.second
}
public func rest<A: Sendable, B: Sendable, C: Sendable, D: Sendable, Z: Sendable>(_ t: T5<A, B, C, D, Z>) -> Z {
    return t.second.second.second.second
}
public func rest<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, Z: Sendable>(_ t: T6<A, B, C, D, E, Z>) -> Z {
  return t.second.second.second.second.second
}
public func rest<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, F: Sendable, Z: Sendable>(_ t: T7<A, B, C, D, E, F, Z>) -> Z {
    return t.second.second.second.second.second.second
}

public func over1<A: Sendable, R: Sendable, Z: Sendable>(_ o: @escaping @Sendable (A) -> R) -> @Sendable (T2<A, Z>) -> T2<R, Z> {
    return { t in o(t.first) .*. t.second }
}
public func over2<A: Sendable, B: Sendable, R: Sendable, Z: Sendable>(_ o: @escaping @Sendable (B) -> R) -> @Sendable (T3<A, B, Z>) -> T3<A, R, Z> {
    return { t in get1(t) .*. o(get2(t)) .*. rest(t) }
}
public func over3<A: Sendable, B: Sendable, C: Sendable, R: Sendable, Z: Sendable>(_ o: @escaping @Sendable (C) -> R) -> @Sendable (T4<A, B, C, Z>) -> T4<A, B, R, Z> {
    return { t in get1(t) .*. get2(t) .*. o(get3(t)) .*. rest(t) }
}
public func over4<A: Sendable, B: Sendable, C: Sendable, D: Sendable, R: Sendable, Z: Sendable>(_ o: @escaping @Sendable (D) -> R) -> @Sendable (T5<A, B, C, D, Z>) -> T5<A, B, C, R, Z> {
    return { t in get1(t) .*. get2(t) .*. get3(t) .*. o(get4(t)) .*. rest(t) }
}
public func over5<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, R: Sendable, Z: Sendable>(_ o: @escaping @Sendable (E) -> R) -> @Sendable (T6<A, B, C, D, E, Z>) -> T6<A, B, C, D, R, Z> {
    return { t in get1(t) .*. get2(t) .*. get3(t) .*. get4(t) .*. o(get5(t)) .*. rest(t) }
}
public func over6<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, F: Sendable, R: Sendable, Z: Sendable>(_ o: @escaping @Sendable (F) -> R) -> @Sendable (T7<A, B, C, D, E, F, Z>) -> T7<A, B, C, D, E, R, Z> {
    return { t in get1(t) .*. get2(t) .*. get3(t) .*. get4(t) .*. get5(t) .*. o(get6(t)) .*. rest(t) }
}

public func lift<A: Sendable>(_ a: A) -> Tuple1<A> {
    return a .*. unit
}
public func lift<A: Sendable, B: Sendable>(_ tuple: (A, B)) -> Tuple2<A, B> {
    return tuple.0 .*. tuple.1 .*. unit
}
public func lift<A: Sendable, B: Sendable, C: Sendable>(_ tuple: (A, B, C)) -> Tuple3<A, B, C> {
    return tuple.0 .*. tuple.1 .*. tuple.2 .*. unit
}
public func lift<A: Sendable, B: Sendable, C: Sendable, D: Sendable>(_ tuple: (A, B, C, D)) -> Tuple4<A, B, C, D> {
    return tuple.0 .*. tuple.1 .*. tuple.2 .*. tuple.3 .*. unit
}
public func lift<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable>(_ tuple: (A, B, C, D, E)) -> Tuple5<A, B, C, D, E> {
    return tuple.0 .*. tuple.1 .*. tuple.2 .*. tuple.3 .*. tuple.4 .*. unit
}
public func lift<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, F: Sendable>(_ tuple: (A, B, C, D, E, F)) -> Tuple6<A, B, C, D, E, F> {
    return tuple.0 .*. tuple.1 .*. tuple.2 .*. tuple.3 .*. tuple.4 .*. tuple.5 .*. unit
}

public func lower<A: Sendable>(_ tuple: Tuple1<A>) -> A {
    return get1(tuple)
}
public func lower<A: Sendable, B: Sendable>(_ tuple: Tuple2<A, B>) -> (A, B) {
    return (
        tuple
        |>
        { get1($0) },
        tuple
        |>
        { get2($0) } )
}
public func lower<A: Sendable, B: Sendable, C: Sendable>(_ tuple: Tuple3<A, B, C>) -> (A, B, C) {
    return (
        tuple
        |>
        { get1($0) },
        tuple
        |>
        { get2($0) },
        tuple
        |>
        { get3($0) })
}
public func lower<A: Sendable, B: Sendable, C: Sendable, D: Sendable>(_ tuple: Tuple4<A, B, C, D>) -> (A, B, C, D) {
    return (
        tuple
        |>
        { get1($0) },
        tuple
        |>
        { get2($0) },
        tuple
        |>
        { get3($0) },
        tuple
        |>
        { get4($0) })
}
public func lower<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable>(_ tuple: Tuple5<A, B, C, D, E>) -> (A, B, C, D, E) {
    return (
        tuple
        |>
        { get1($0) },
        tuple
        |>
        { get2($0) },
        tuple
        |>
        { get3($0) },
        tuple
        |>
        { get4($0) },
        tuple
        |>
        { get5($0) })
}
public func lower<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, F: Sendable>(_ tuple: Tuple6<A, B, C, D, E, F>) -> (A, B, C, D, E, F) {
    return (
        tuple
        |>
        { get1($0) },
        tuple
        |>
        { get2($0) },
        tuple
        |>
        { get3($0) },
        tuple
        |>
        { get4($0) },
        tuple
        |>
        { get5($0) },
        tuple
        |>
        { get6($0) })
}

public func require1<A: Sendable, Z: Sendable>(_ x: T2<A?, Z>) -> T2<A, Z>? {
    return get1(x)
        .map {
            over1(const($0))
            <|
            x
        }
}
public func require2<A: Sendable, B: Sendable, Z: Sendable>(_ x: T3<A, B?, Z>) -> T3<A, B, Z>? {
    return get2(x)
        .map {
            over2(const($0))
            <|
            x
        }
}
public func require3<A: Sendable, B: Sendable, C: Sendable, Z: Sendable>(_ x: T4<A, B, C?, Z>) -> T4<A, B, C, Z>? {
    return get3(x)
        .map {
            over3(const($0))
            <|
            x
        }
}

extension Tuple: Equatable where A: Equatable, B: Equatable {
    public static func == (lhs: Tuple, rhs: Tuple) -> Bool {
        return lhs.first == rhs.first && lhs.second == rhs.second
    }
}

extension Tuple: Comparable where A: Comparable, B: Comparable {
    public static func < (lhs: Tuple, rhs: Tuple) -> Bool {
        return lhs.first < rhs.first && lhs.second < rhs.second
    }
}

extension Tuple: Semigroup where A: Semigroup, B: Semigroup {
    public static func <> (lhs: Tuple, rhs: Tuple) -> Tuple {
        return Tuple(first: lhs.first <> rhs.first, second: lhs.second <> rhs.second)
    }
}

extension Tuple: Monoid where A: Monoid, B: Monoid {
    public static var empty: Tuple<A, B> {
        return Tuple(first: A.empty, second: B.empty)
    }
}

extension Tuple: NearSemiring where A: NearSemiring, B: NearSemiring {
    public static func + (lhs: Tuple<A, B>, rhs: Tuple<A, B>) -> Tuple<A, B> {
        return Tuple(first: lhs.first + rhs.first, second: lhs.second + rhs.second)
    }

    public static func * (lhs: Tuple<A, B>, rhs: Tuple<A, B>) -> Tuple<A, B> {
        return Tuple(first: lhs.first * rhs.first, second: lhs.second * rhs.second)
    }

    public static var zero: Tuple<A, B> {
        return Tuple(first: A.zero, second: B.zero)
    }
}

extension Tuple: Semiring where A: Semiring, B: Semiring {
    public static var one: Tuple<A, B> {
        return Tuple(first: A.one, second: B.one)
    }
}

extension Tuple: Ring where A: Ring, B: Ring {
    public static func - (lhs: Tuple<A, B>, rhs: Tuple<A, B>) -> Tuple<A, B> {
        return Tuple(first: lhs.first - rhs.first, second: lhs.second - rhs.second)
    }
}

extension Tuple: HeytingAlgebra where A: HeytingAlgebra & Semigroup, B: HeytingAlgebra & Semigroup {
    public static var ff: Tuple<A, B> {
        return Tuple(first: A.ff, second: B.ff)
    }

    public static var tt: Tuple<A, B> {
        return Tuple(first: A.tt, second: B.tt)
    }

    public static func implies(_ a: Tuple<A, B>, _ b: Tuple<A, B>) -> Tuple<A, B> {
        return Tuple(first: A.implies(a.first, b.first), second: B.implies(a.second, b.second))
    }

    public static func && (lhs: Tuple<A, B>, rhs: @autoclosure @Sendable () throws -> Tuple<A, B>) rethrows -> Tuple<A, B> {
        let rhs = try rhs()
        return Tuple(first: lhs.first && rhs.first, second: lhs.second && rhs.second)
    }

    public static func || (lhs: Tuple<A, B>, rhs: @autoclosure @Sendable () throws -> Tuple<A, B>) rethrows -> Tuple<A, B> {
        let rhs = try rhs()
        return Tuple(first: lhs.first || rhs.first, second: lhs.second || rhs.second)
    }

    public static prefix func ! (not: Tuple<A, B>) -> Tuple<A, B> {
        return Tuple(first: !not.first, second: !not.second)
    }
}
