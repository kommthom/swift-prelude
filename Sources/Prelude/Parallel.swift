import Dependencies
import Dispatch

public final class Parallel<A: Sendable> : Sendable {
    private let compute: @Sendable () async -> A

    public init(_ compute: @escaping @Sendable () async -> A) {
        self.compute = withEscapedDependencies { continuation in
            let computed: AsyncValue<A> = .init()
            return {
                if await !computed.isEmpty { return await computed.wrapped! }
                let result = await continuation.yield { await compute() }
                await computed.set(result)
                return result
            }
        }
    }

    public convenience init(_ compute: @escaping @Sendable (@escaping @Sendable (A) -> ()) -> ()) {
        self.init {
            await withCheckedContinuation { continuation in
                compute { a in
                    continuation.resume(returning: a)
                }
            }
        }
    }

    public func run(_ callback: @escaping @Sendable (A) -> ()) {
        Task {
            await callback(self.compute())
        }
    }
    
    public func asyncRun(_ callback: @escaping @Sendable (A) async -> ()) async {
        await callback(self.compute())
    }
}

public func parallel<A: Sendable>(_ io: IO<A>) -> Parallel<A> {
    return .init {
        await io.performAsync()
    }
}

extension Parallel {
    public var sequential: IO<A> {
        return .init { callback in
            self.run(callback)
        }
    }
}

public func sequential<A: Sendable>(_ x: Parallel<A>) -> IO<A> {
    return x.sequential
}

// MARK: - Functor

extension Parallel {
    public func map<B: Sendable>(_ f: @escaping @Sendable (A) -> B) -> Parallel<B> {
        return .init { compute in
            self.run(compute <<< f)
        }
    }

    public static func <¢> <B: Sendable>(f: @escaping @Sendable (A) -> B, x: Parallel<A>) -> Parallel<B> {
        return x.map(f)
    }
}

public func map<A: Sendable, B: Sendable>(_ f: @escaping @Sendable (A) -> B) -> @Sendable (Parallel<A>) -> Parallel<B> {
    return { f <¢> $0 }
}

// MARK: - Apply

extension Parallel {
    public func apply<B: Sendable>(_ f: Parallel<@Sendable (A) -> B>) -> Parallel<B> {
        return .init {
            async let f = f.compute()
            async let x = self.compute()
            return await f(x)
        }
    }

    public static func <*> <B: Sendable>(f: Parallel<@Sendable (A) -> B>, x: Parallel<A>) -> Parallel<B> {
        return x.apply(f)
    }
}

public func apply<A: Sendable, B: Sendable>(_ f: Parallel<@Sendable (A) -> B>) -> @Sendable (Parallel<A>) -> Parallel<B> {
    return { f <*> $0 }
}

// MARK: - Applicative

public func pure<A: Sendable>(_ x: A) -> Parallel<A> {
    return { parallel($0) }
        <<<
        { pure($0) }
        <|
        x
}

// MARK: - Traversable

public func traverse<C: Sendable, A: Sendable, B: Sendable>(_ f: @escaping @Sendable (A) -> Parallel<B>) -> @Sendable (C) -> Parallel<[B]> where C: Collection, C.Element == A {
    return { xs in
        guard !xs.isEmpty else { return pure([]) }
        return Parallel<[B]> { callback in
            Task {
                let allResults = await withTaskGroup(of: (Int, B)?.self, returning: [B].self, body: { taskGroup in
                    // Loop through array
                    for (idx, parallel) in xs.map(f).enumerated() {
                        //for x in xs {
                        // Add child task to task group
                        taskGroup.addTask {
                            // Execute operation
                            let result: AsyncValue<(Int, B)?> = AsyncValue()
                            await parallel.asyncRun { b in
                                // Return child task result
                                await result.set((idx, b))
                            }
                            return await result.wrapped!
                        }
                    }
                    // Collect results of all child task in an AsyncArray
                  let childTaskResults: AsyncArray<B?> = AsyncArray<B?>.init([B?](repeating: nil, count: Int(xs.count)))
                    for await result in taskGroup {
                        // Set operation name as key and operation result as value
                        await childTaskResults.set(result?.1, idx: result!.0)
                    }
                    // All child tasks finish running, thus task group result
                     return await childTaskResults.wrapped as! [B]
                } )
                callback(allResults)
            }
        }
    }
}

public func sequence<C: Sendable, A: Sendable>(_ xs: C) -> Parallel<[A]> where C: Collection, C.Element == Parallel<A> {
    return xs |> traverse( { a in id (a)} )
}

// MARK: - Alt

extension Parallel: Alt {
    public static func <|> (lhs: Parallel, rhs: @autoclosure @escaping @Sendable () -> Parallel) -> Parallel {
        return .init { f in
            let finished: AsyncValue<Bool> = .init(false)
            let callback: @Sendable (A) async -> () = {
                guard await !finished.wrapped! else { return }
                await finished.set(true)
                f($0)
            }
            Task {
                await lhs.asyncRun(callback)
                await rhs().asyncRun(callback)
            }
        }
    }
}

// MARK: - Semigroup

extension Parallel: Semigroup where A: Semigroup {
    public static func <> (lhs: Parallel, rhs: Parallel) -> Parallel {
        return curry(
                { $0 <> $1 }
            )
            <¢>
            lhs
            <*>
            rhs
    }
}

// MARK: - Monoid

extension Parallel: Monoid where A: Monoid {
    public static var empty: Parallel {
        return pure(A.empty)
    }
}
