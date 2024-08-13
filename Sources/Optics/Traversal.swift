import Prelude

// MARK: - Getter

public func traversed<S: Sequence>(_ f: Forget<S.Element, S.Element, S.Element>)  -> Forget<S.Element, S, S> where S.Element: Monoid {
    return .init(foldMap(f.unwrap))
}

//public func traversed<A: Sendable>(_ f: Forget<A, A, A>) -> Forget<A, [A], [A]> where A: Monoid {
//    return .init(foldMap(f.unwrap))
//}

public func traversed<A: Sendable>(_ f: Forget<A, A, A>) -> Forget<A, A?, A?> where A: Monoid {
    return .init(foldMap(f.unwrap))
}

// MARK: - Setter

//public func traversed<C: MutableCollection>(_ f: @escaping @Sendable (C.Element) -> C.Element) -> (C) -> C {
//  return { xs in
//    var copy = xs
//    var idx = xs.startIndex
//    while idx < xs.endIndex {
//      defer { idx = xs.index(after: idx) }
//      copy[idx] = f(xs[idx])
//    }
//    return copy
//  }
//}

public func traversed<A: Sendable, B: Sendable>(_ f: @escaping @Sendable (A) -> B) -> @Sendable ([A]) -> [B] {
    return { xs in xs.map(f) }
}

public func traversed<A: Sendable, B: Sendable>(_ f: @escaping @Sendable (A) -> B) -> @Sendable (A?) -> B? {
    return { x in x.map(f) }
}
