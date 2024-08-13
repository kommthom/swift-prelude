import Prelude

struct ArrayStar<A: Sendable, B: Sendable>: Sendable {
    let call: @Sendable (A) -> [B]
    init(_ call: @escaping @Sendable (A) -> [B]) {
        self.call = call
    }

    func map<C: Sendable>(_ f: @escaping @Sendable (B) -> C) -> ArrayStar<A, C> {
        return .init(
            Prelude.map(
                f
            )
            <<<
            self.call
        )
    }

    func apply<C: Sendable>(_ f: ArrayStar<A, @Sendable (B) -> C>) -> ArrayStar<A, C> {
        return .init { a in
            f.call(a) <*> self.call(a)
        }
    }

    func dimap<C: Sendable, D: Sendable>(_ f: @escaping @Sendable (C) -> A, _ g: @escaping @Sendable (B) -> D) -> ArrayStar<C, D> {
        return .init(
            f
            >>>
            self.call
            >>>
            Prelude.map(
                g
            )
        )
    }
}

func pure<A: Sendable, B: Sendable>(_ b: B) -> ArrayStar<A, B> {
    return .init(const(pure(b)))
}

func traverseOf<S: Sendable, T: Sendable, A: Sendable, B: Sendable>(_ optic: @escaping @Sendable (ArrayStar<A, B>) -> ArrayStar<S, T>) -> (@escaping @Sendable (A) -> [B]) -> @Sendable (S) -> [T] {
    return { f in
        return { s in
            optic(.init(f)).call(s)
        }
    }
}
