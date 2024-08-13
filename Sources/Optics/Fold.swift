import Prelude

infix operator ^?: infixl8 // previewOn

struct First<A: Sendable>: Monoid {
    let unwrap: A?

    init(_ unwrap: A?) {
        self.unwrap = unwrap
    }

    static func <>(lhs: First<A>, rhs: First<A>) -> First<A> {
        return .init(lhs.unwrap ?? rhs.unwrap)
    }
    static var empty: First<A> { return .init(nil) }
}

public typealias Fold<R, S, T, A, B> = @Sendable (Forget<R, A, B>) -> Forget<R, S, T>

func under<A: Sendable, B: Sendable>(_ f: @escaping @Sendable (First<A>) -> First<B>) -> @Sendable (A?) -> B? {
    return { a in f(.init(a)).unwrap }
}

func unwrap<A: Sendable>(_ wrapped: First<A>) -> A? {
    return wrapped.unwrap
}

func preview<S: Sendable, T: Sendable, A: Sendable, B: Sendable>(_ fold: @escaping Fold<First<A>, S, T, A, B>) -> @Sendable (S) -> A? {
    return { unwrap($0) }
        <<<
        foldMapOf(fold)(
            { First.init($0) }
            <<<
            { A?.some($0) }
        )
}

func previewOn<S: Sendable, T: Sendable, A: Sendable, B: Sendable>(_ source: S, _ fold: @escaping Fold<First<A>, S, T, A, B>) -> A? {
    return preview(fold)
        <|
        source
}

func ^? <S: Sendable, T: Sendable, A: Sendable, B: Sendable> (source: S, fold: @escaping Fold<First<A>, S, T, A, B>) -> A? {
    return previewOn(source, fold)
}

func foldMapOf<R: Sendable, S: Sendable, T: Sendable, A: Sendable, B: Sendable>(_ fold: @escaping Fold<R, S, T, A, B>) -> @Sendable (@escaping @Sendable (A) -> R) -> @Sendable (S) -> R {
    return { f in
        { fold(
                .init(f)
            )
            .unwrap($0) }
    }
}

func foldOf<S: Sendable, T: Sendable, A: Sendable, B: Sendable>(_ fold: @escaping Fold<A, S, T, A, B>) -> (S) -> A {
    return foldMapOf(fold)(
        { id($0) }
    )
}

//func allOf<R: HeytingAlgebra, S, T, A, B>(_ fold: Fold

//-- | Whether all foci of a `Fold` satisfy a predicate.
//allOf :: forall s t a b r. HeytingAlgebra r => Fold (Conj r) s t a b -> (a -> r) -> s -> r
//allOf p f = unwrap <<< foldMapOf p (Conj <<< f)
