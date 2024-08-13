public func tuple<A: Sendable, B: Sendable>(_ x: A) -> @Sendable (B) -> (A, B) {
    return { y in (x, y) }
}
public func tuple3<A: Sendable, B: Sendable, C: Sendable>(_ a: A) -> @Sendable (B) -> @Sendable (C) -> (A, B, C) {
    return { b in { c in (a, b, c) } }
}
public func tuple4<A: Sendable, B: Sendable, C: Sendable, D: Sendable>(_ a: A) -> @Sendable (B) -> @Sendable (C) -> @Sendable (D) -> (A, B, C, D) {
   return { b in { c in { d in (a, b, c, d) } } }
}

public func first<A: Sendable, B: Sendable>(_ x: (A, B)) -> A {
    return x.0
}

public func second<A: Sendable, B: Sendable>(_ x: (A, B)) -> B {
  return x.1
}

// MARK: - Semigroupoid

public func >>> <A: Sendable, B: Sendable, C: Sendable>(_ ab: (A, B), _ bc: (B, C)) -> (A, C) {
    return (ab.0, bc.1)
}

public func <<< <A: Sendable, B: Sendable, C: Sendable>(_ bc: (B, C), _ ab: (A, B)) -> (A, C) {
    return (ab.0, bc.1)
}

// MARK: - Semigroup

public func <> <A: Semigroup, B: Semigroup>(_ ab1: (A, B), _ ab2: (A, B)) -> (A, B) {
    return (ab1.0 <> ab2.0, ab1.1 <> ab2.1)
}

// MARK: - Monoid

public func empty<A: Monoid, B: Monoid>() -> (A, B) {
    return (A.empty, B.empty)
}
