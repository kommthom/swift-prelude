import Either
import Prelude

//class Profunctor p <= Choice p where
//  left :: forall a b c. p a b -> p (Either a c) (Either b c)
//  right :: forall a b c. p b c -> p (Either a b) (Either a c)

//type Review s t a b = Optic Tagged s t a b
//type Review' s a = Review s s a a

//newtype Tagged a b = Tagged b

//type Prism s t a b = forall p. Choice p => Optic p s t a b
//type Prism' s a = Prism s s a a

public typealias Market<A: Sendable, B: Sendable, S: Sendable, T: Sendable> = (review: @Sendable (B) -> T, preview: @Sendable (S) -> Either<T, A>)

public typealias APrism<S: Sendable, T: Sendable, A: Sendable, B: Sendable> = @Sendable (Market<A, B, A, B>) -> Market<A, B, S, T>

public func withPrism<S: Sendable, T: Sendable, A: Sendable, B: Sendable, R: Sendable>(_ prism: APrism<S, T, A, B>, _ f: @Sendable (Market<A, B, S, T>) -> R) -> R {
    return f
        <|
        prism(
            (
                { id($0) },
                { Either.right($0) }
            )
        )
}

public func matching<S: Sendable, T: Sendable, A: Sendable, B: Sendable>(_ prism: @escaping APrism<S, T, A, B>) -> @Sendable (S) -> Either<T, A> {
    return { s in
        withPrism(prism) { $0.preview <| s }
    }
}

public func `is`<S: Sendable, T: Sendable, A: Sendable, B: Sendable, R: HeytingAlgebra>(_ prism: @escaping APrism<S, T, A, B>) -> @Sendable (S) -> R {
    return either(const(R.ff), const(R.tt)) <<< matching(prism)
}

public func isnt<S: Sendable, T: Sendable, A: Sendable, B: Sendable, R: HeytingAlgebra>(_ prism: @escaping APrism<S, T, A, B>) -> @Sendable (S) -> R {
    return ( { !$0 } )
        <<<
        `is`(
            prism
        )
}

// Optional

public func some<A: Sendable, B: Sendable>(_ a2b: @escaping @Sendable (A) -> B) -> @Sendable (A?) -> Either<B?, B?> {
    return { some in
        some
        .map(
            a2b
            >>>
            { Either.right($0) }
        ) ?? .left(.none)
    }
}

public func none<A: Sendable, B: Sendable>(_ a2b: @escaping @Sendable (()) -> ()) -> @Sendable (A?) -> Either<B?, B?> {
  return { some in some.map(const(Either.left(.none))) ?? .right(.none) }
}
