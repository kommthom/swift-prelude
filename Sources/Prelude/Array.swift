public func uncons<A: Sendable>(_ xs: [A]) -> (A, [A])? {
    guard let x = xs.first else { return nil }
    return (x, Array(xs.dropFirst()))
}

public func <*> <A: Sendable, B: Sendable> (fs: [(A) -> B], xs: [A]) -> [B] {
    return fs.flatMap { f in xs.map(f) }
}

public func foldMap<A: Sendable, M: Monoid>(_ f: @escaping  @Sendable (A) -> M) -> @Sendable ([A]) -> M {
    return { xs in
        xs.reduce(M.empty) { accum, x in accum <> f(x) }
    }
}

public func partition<A: Sendable>(_ p: @escaping @Sendable (A) -> Bool) -> @Sendable ([A]) -> ([A], [A]) {
    return { xs in
        xs.reduce(into: ([], [])) { accum, x in
            if p(x) {
                accum.0.append(x)
            } else {
                accum.1.append(x)
            }
        }
  }
}

public func elem<A: Equatable & Sendable>(_ x: A) -> @Sendable ([A]) -> Bool {
    return { xs in xs.contains(x) }
}

public func elem<A: Equatable & Sendable>(of xs: [A]) -> @Sendable (A) -> Bool {
    return { x in xs.contains(x) }
}

public func lookup<A: Equatable & Sendable, B: Sendable>(_ x: A) -> @Sendable ([(A, B)]) -> B? {
    return { pairs in
        pairs.first { pair in pair.0 == x }.map(second)
    }
}

public func zipWith<A: Sendable, B: Sendable, C: Sendable>(_ f: @escaping @Sendable (A, B) -> C) -> @Sendable ([A]) -> @Sendable ([B]) -> [C] {
    return { xs in
        return { ys in
            return zip(xs, ys).map { f($0.0, $0.1) }
        }
    }
}

public func sorted<A: Sendable>(by f: @escaping  @Sendable (A, A) -> Bool) -> @Sendable ([A]) -> [A] {
    return { xs in
        xs.sorted(by: f)
    }
}

public func replicate<A: Sendable>(_ n: Int) -> @Sendable (A) -> [A] {
    return { a in (1...n).map(const(a)) }
}

// MARK: - Applicative

public func pure<A: Sendable>(_ a: A) -> [A] {
    return [a]
}

// MARK: - Point-free Standard Library

public func joined(separator: String) -> @Sendable ([String]) -> String {
    return { xs in
        xs.joined(separator: separator)
    }
}
