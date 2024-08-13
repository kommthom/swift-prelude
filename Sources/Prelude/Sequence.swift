public func <¢> <A: Sendable, S: Sequence & Sendable>(f: @Sendable (S.Element) -> A, xs: S) -> [A] {
    return xs.map(f)
}

public func >>- <S: Sequence & Sendable, T: Sequence & Sendable>(f: (S.Element) -> T, xs: S) -> [T.Element] {
    return xs.flatMap(f)
}

public func catOptionals<S: Sequence & Sendable, A: Sendable>(_ xs: S) -> [A] where S.Element == A? {
    return xs 
        |>
        mapOptional(
            { id($0) }
        )
}

public func mapOptional<S: Sequence & Sendable, A: Sendable>(_ f: @escaping @Sendable (S.Element) -> A?) -> @Sendable (S) -> [A] {
    return { xs in
      xs.compactMap(f)
    }
}

// MARK: - Functor

extension Sequence {
    public static func <¢> <A: Sendable>(f: @Sendable (Element) -> A, xs: Self) -> [A] {
        return xs.map(f)
    }
}

public func map<S: Sequence & Sendable, A: Sendable>(_ f: @escaping @Sendable (S.Element) -> A) -> @Sendable (S) -> [A] {
    return { xs in
        return f <¢> xs
    }
}

// MARK: - Apply

extension Sequence {
    public func apply<S: Sequence & Sendable, A: Sendable>(_ fs: S) -> [A] where S.Element == ((Element) -> A) {
        // return fs.flatMap(self.map) // https://bugs.swift.org/browse/SR-5251
        return fs.flatMap { f in self.map { x in f(x) } }
    }

    public static func <*> <S: Sequence & Sendable, A: Sendable>(fs: S, xs: Self) -> [A] where S.Element == ((Element) -> A) {
        // return xs.apply(fs) // https://bugs.swift.org/browse/SR-5251
        return fs.flatMap { f in xs.map { x in f(x) } }
    }
}

public func apply<S: Sequence & Sendable, T: Sequence & Sendable, A: Sendable>(_ fs: S) -> @Sendable (T) -> [A] where S.Element == ((T.Element) -> A) {
    return { xs in
        // fs <*> xs // https://bugs.swift.org/browse/SR-5251
        fs.flatMap { f in xs.map { x in f(x) } }
    }
}

// MARK: - Bind/Monad

public func flatMap<S: Sequence & Sendable, A: Sendable>(_ f: @escaping @Sendable (S.Element) -> [A]) -> @Sendable (S) -> [A] {
    return { xs in
        xs.flatMap(f)
    }
}

// MARK: - Monoid

extension Sequence where Element: Monoid {
    public func concat() -> Element {
        return self.reduce(.empty, <>)
    }
}

public func concat<S: Sequence & Sendable>(_ xs: S) -> S.Element where S.Element: Monoid {
    return xs.reduce(.empty, <>)
}

// MARK: - Foldable/Sequence

extension Sequence {
    public func foldMap<M: Monoid>(_ f: @escaping @Sendable (Element) -> M) -> M {
        return self.reduce(M.empty) { m, x in m <> f(x) }
    }
}

public func foldMap<S: Sequence & Sendable, M: Monoid>(_ f: @escaping @Sendable (S.Element) -> M) -> @Sendable (S) -> M {
    return { xs in
        xs.foldMap(f)
    }
}

// MARK: - Point-free Standard Library

public func contains<S: Sequence & Sendable>(_ x: S.Element) -> @Sendable (S) -> Bool where S.Element: Equatable & Sendable {
    return { xs in
        xs.contains(x)
    }
}

public func contains<S: Sequence & Sendable>(where p: @escaping @Sendable (S.Element) -> Bool) -> @Sendable (S) -> Bool {
    return { xs in
        xs.contains(where: p)
    }
}

public func filter<S: Sequence & Sendable>(_ p: @escaping @Sendable (S.Element) -> Bool) -> @Sendable (S) -> [S.Element] {
    return { xs in
        xs.filter(p)
    }
}

public func flatMap<S: Sequence & Sendable, T: Sequence & Sendable>(_ f: @escaping @Sendable (S.Element) -> T) -> @Sendable (S) -> [T.Element] {
    return { xs in
        xs.flatMap(f)
    }
}

public func forEach<S: Sequence & Sendable>(_ f: @escaping @Sendable (S.Element) -> ()) -> @Sendable (S) -> () {
    return { xs in
        xs.forEach(f)
    }
}

public func map<A: Sendable, S: Sequence & Sendable>(_ f: @escaping @Sendable (S.Element) -> A) -> @Sendable (S) -> [A] {
    return { xs in
        xs.map(f)
    }
}

public func reduce<A: Sendable, S: Sequence & Sendable>(_ f: @escaping @Sendable (A, S.Element) -> A) -> @Sendable (A) -> @Sendable (S) -> A {
    return { a in { xs in
        xs.reduce(a, f)
    } }
}

public func sorted<S: Sequence & Sendable>(_ xs: S) -> [S.Element] where S.Element: Comparable & Sendable {
    return xs.sorted()
}

public func sorted<S: Sequence & Sendable>(by f: @escaping @Sendable (S.Element, S.Element) -> Bool) -> @Sendable (S) -> [S.Element] {
    return { xs in
        xs.sorted(by: f)
    }
}

public func zipWith<S: Sequence & Sendable, T: Sequence & Sendable, A: Sendable>(_ f: @escaping @Sendable (S.Element, T.Element) -> A) -> @Sendable (S) -> @Sendable (T) -> [A] {
    return { xs in
        return { ys in
            return zip(xs, ys).map { f($0.0, $0.1) }
        }
    }
}

public func intersperse<A: Sendable>(_ a: A) -> @Sendable ([A]) -> [A] {
    return { xs in
        var result = [A]()
        for x in xs.dropLast() {
            result.append(x)
            result.append(a)
        }
        if let last = xs.last { result.append(last) } //xs.last.do { result.append($0) }
        return result
    }
}
