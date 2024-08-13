import Prelude

public typealias E2<A, Z> = Either<A, Z>
public typealias E3<A, B, Z> = Either<A, E2<B, Z>>
public typealias E4<A, B, C, Z> = Either<A, E3<B, C, Z>>
public typealias E5<A, B, C, D, Z> = Either<A, E4<B, C, D, Z>>
public typealias E6<A, B, C, D, E, Z> = Either<A, E5<B, C, D, E, Z>>
public typealias E7<A, B, C, D, E, F, Z> = Either<A, E6<B, C, D, E, F, Z>>

public typealias Either1<A> = E2<A, Never>
public typealias Either2<A, B> = E3<A, B, Never>
public typealias Either3<A, B, C> = E4<A, B, C, Never>
public typealias Either4<A, B, C, D> = E5<A, B, C, D, Never>
public typealias Either5<A, B, C, D, E> = E6<A, B, C, D, E, Never>
public typealias Either6<A, B, C, D, E, F> = E7<A, B, C, D, E, F, Never>

public func inj1<A: Sendable, Z: Sendable>(_ v: A) -> E2<A, Z> {
    return .left(v)
}

public func inj2<A: Sendable, B: Sendable, Z: Sendable>(_ v: B) -> E3<A, B, Z> {
    return .right(.left(v))
}

public func inj3<A: Sendable, B: Sendable, C: Sendable, Z: Sendable>(_ v: C) -> E4<A, B, C, Z> {
    return .right(.right(.left(v)))
}

public func inj4<A: Sendable, B: Sendable, C: Sendable, D: Sendable, Z: Sendable>(_ v: D) -> E5<A, B, C, D, Z> {
    return .right(.right(.right(.left(v))))
}

public func inj5<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, Z: Sendable>(_ v: E) -> E6<A, B, C, D, E, Z> {
    return .right(.right(.right(.right(.left(v)))))
}

public func inj6<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, F: Sendable, Z: Sendable>(_ v: F) -> E7<A, B, C, D, E, F, Z> {
    return .right(.right(.right(.right(.right(.left(v))))))
}

public func get1<A: Sendable, Z: Sendable>(_ e: E2<A, Z>) -> A? {
    if case let .left(v) = e { return v }
    return nil
}

public func get2<A: Sendable, B: Sendable, Z: Sendable>(_ e: E3<A, B, Z>) -> B? {
    if case let .right(.left(v)) = e { return v }
    return nil
}

public func get3<A: Sendable, B: Sendable, C: Sendable, Z: Sendable>(_ e: E4<A, B, C, Z>) -> C? {
    if case let .right(.right(.left(v))) = e { return v }
    return nil
}

public func get4<A: Sendable, B: Sendable, C: Sendable, D: Sendable, Z: Sendable>(_ e: E5<A, B, C, D, Z>) -> D? {
    if case let .right(.right(.right(.left(v)))) = e { return v }
    return nil
}

public func get5<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, Z: Sendable> (_ e: E6<A, B, C, D, E, Z>) -> E? {
    if case let .right(.right(.right(.right(.left(v))))) = e { return v }
    return nil
}

public func get6<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, F: Sendable, Z: Sendable>(_ e: E7<A, B, C, D, E, F, Z>) -> F? {
    if case let .right(.right(.right(.right(.right(.left(v)))))) = e { return v }
    return nil
}

public func either3<A: Sendable, B: Sendable, C: Sendable, D: Sendable>(_ either: Either3<A, B, C>, _ a2d: (A) -> D, _ b2d: (B) -> D, _ c2d: (C) -> D ) -> D {
    switch either {
    case let .left(a):
      return a2d(a)
    case let .right(.left(b)):
      return b2d(b)
    case let .right(.right(.left(c))):
      return c2d(c)
    }
}

public func at1<A: Sendable, R: Sendable, Z: Sendable>(_ v: R, _ f: @escaping @Sendable (A) -> R) -> @Sendable (E2<A, Z>) -> R {
    return { get1($0).map(f) ?? v }
}

public func at2<A: Sendable, B: Sendable, R: Sendable, Z: Sendable>(_ v: R, _ f: @escaping @Sendable (B) -> R) -> @Sendable (E3<A, B, Z>) -> R {
    return { get2($0).map(f) ?? v }
}

public func at3<A: Sendable, B: Sendable, C: Sendable, R: Sendable, Z: Sendable>(_ v: R, _ f: @escaping @Sendable (C) -> R) -> @Sendable (E4<A, B, C, Z>) -> R {
    return { get3($0).map(f) ?? v }
}

public func at4<A: Sendable, B: Sendable, C: Sendable, D: Sendable, R: Sendable, Z: Sendable>(_ v: R, _ f: @escaping @Sendable (D) -> R) -> @Sendable (E5<A, B, C, D, Z>) -> R {
    return { get4($0).map(f) ?? v }
}

public func at5<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, R: Sendable, Z: Sendable>(_ v: R, _ f: @escaping @Sendable (E) -> R) -> @Sendable (E6<A, B, C, D, E, Z>) -> R {
    return { get5(
            $0
        )
        .map(
            f
        ) ?? v }
}

public func at6<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, F: Sendable, R: Sendable, Z: Sendable>(_ v: R, _ f: @escaping @Sendable (F) -> R) -> @Sendable (E7<A, B, C, D, E, F, Z>) -> R {
    return { get6($0).map(f) ?? v }
}
