import Prelude
import ValidationSemigroup

public func <*> <A: Sendable, B: AsyncSemigroup, E: AsyncSemigroup>(a2b: Event<Validation<E, @Sendable (A) async -> B>>, a: Event<Validation<E, A>>) async -> Event<Validation<E, B>> {
    return await ( { await $0 <*> $1 } )
        <¢>
        (curry(
               { ($0, $1) }
            )
            <¢>
            a2b
            <*>
            a
        )
}

public func pure<E: Sendable, A: Sendable>(_ a: A) async -> Event<Validation<E, A>> {
    return await { await pure($0) }
        <<<
        { pure($0) }
        <|
        a
}
