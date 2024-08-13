//
//  AsyncFunction.swift
//
//
//  Created by Thomas Benninghaus on 08.08.24.
//

import Foundation

public func <| <A: Sendable, B: Sendable> (f: @Sendable (A) async -> B, a: A) async -> B {
    return await f(a)
}

public func |> <A: Sendable, B: Sendable> (a: A, f: @Sendable (A) async -> B) async -> B {
    return await f(a)
}

public func <<< <A: Sendable, B: Sendable, C: Sendable>(_ b2c: @escaping @Sendable (B) async -> C, _ a2b: @escaping @Sendable (A) async -> B) async -> @Sendable (A) async -> C {
    return { a in await b2c(a2b(a)) }
}

public func >>> <A: Sendable, B: Sendable, C: Sendable>(_ a2b: @escaping @Sendable (A) async -> B, _ b2c: @escaping @Sendable (B) async -> C) async -> @Sendable (A) async -> C {
    return { a in await b2c(a2b(a)) }
}

public func curry<A: Sendable, B: Sendable, C: Sendable>(_ function: @escaping @Sendable (A, B) async -> C) async -> @Sendable (A) async -> @Sendable (B) async -> C {
    return { @Sendable (a: A) async -> @Sendable (B) async -> C in
        { @Sendable (b: B) async  -> C in
            await function(a, b)
        }
    }
}

public func concatCurry<A: AsyncSemigroup>() async -> @Sendable (A) async -> @Sendable (A) async -> A {
    return { @Sendable (a: A) async -> @Sendable (A) async -> A in
        { @Sendable (b: A) async  -> A in
            return await a <> b
        }
    }
}

public func tupleCurry<A: Sendable, B: Sendable>() async -> @Sendable (A) async -> @Sendable (B) async -> (A, B) {
    return { @Sendable (a: A) async -> @Sendable (B) async -> (A, B) in
        { @Sendable (b: B) async  -> (A, B) in
            return (a, b)
        }
    }
}
