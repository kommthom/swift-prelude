import Prelude

public final class Event<A: Sendable>: Sendable {
    public let subs: AsyncArray<@Sendable (A) async -> Void>
    public let latest: AsyncValue<A>?
    
    public init(events: [@Sendable (A) async -> Void] = .init(), latest: A? = nil) async {
        self.subs = AsyncArray<@Sendable (A) async -> Void>()
        self.latest = AsyncValue(latest)
        await events.asyncForEach { e in
            await self.subscribe(e)
        }
    }
    
    public func subscribe(_ f: @escaping @Sendable (A) async -> ()) async {
        do {
            try await run {
                await self.subs.append(f)
            } defer: { await self.latest?.asyncMap(f) }
        } catch {}
    }

    internal func push(_ a: A) async {
        do {
            try await run {
                await self.subs.asyncForEach { sub in
                    await sub(a)
                }
            } defer: { await self.latest?.set(a) }
        } catch {}
    }

    public static func create() async -> (Event, @Sendable (A) async -> ()) {
        let event = await Event()
        let push = { @Sendable a in
            await event.push(a)
        }
        return (event, push)
    }

    public static func never() async -> Event {
        return await Event()
    }

    public static func combine<B: Sendable>(_ a: Event, _ b: Event<B>) async -> Event<(A, B)> {
        return await /*tupleCurry(
                //{ ($0, $1) }
            )
            <¢>*/
            //a
            //<*>
            //b
            b.apply(
                await a.map(
                    { @Sendable (a: A) async -> @Sendable (B) async -> (A, B) in
                        { @Sendable (b: B) async  -> (A, B) in
                            return (a, b)
                        }
                    } // tupleCurry
                )
            )
    }

    public static func merge(_ es: Event...) async -> Event {
        return await self.merge(es)
    }

    public static func merge(_ es: [Event]) async -> Event {
        let event = await Event()
        await es.asyncForEach { e in
            await e.subscribe { a in
                await event.push(a)
            }
        }
        return event
    }

    public func filter(_ predicate: @escaping @Sendable (A) -> Bool) async -> Event {
        let event = await Event()
        await self.subscribe { a in
            if predicate(a) {
                await event.push(a)
            }
        }
        return event
    }

    public func reduce<B: Sendable>(_ initialResult: B, _ nextPartialResult: @escaping @Sendable (B, A) async -> B) async -> Event<B> {
        let event = await Event<B>()
        let latest = AsyncValue(initialResult)
        await self.subscribe { a in
            let nextResult = await nextPartialResult(await latest.wrapped!, a)
            await latest.set(nextResult)
            await event.push(nextResult)
        }
        return event
    }

    public func count() async -> Event<Int> {
        return await self.reduce(0) { n, _ in n + 1 }
    }

    public func withLast() async -> Event<(now: A, last: A?)> {
        let event = await Event<(now: A, last: A?)>()
        await self.subscribe { a in
            let latestResult = await self.latest?.wrapped
            await event.push((a, latestResult))
        }
        return event
    }

    public func sample<B: Sendable>(on other: Event<B>) async -> Event {
        let event = await Event()
        await other.subscribe { _ in
            if let latestResult = await self.latest?.wrapped {
                await event.push(latestResult)
            }
        }
        return event
    }

    public func mapOptional<B: Sendable>(_ f: @escaping @Sendable (A) async -> B?) async -> Event<B> {
        let event = await Event<B>()
        await self.subscribe { a in
            if let b = await f(a) {
                await event.push(b)
          }
        }
        return event
    }

    public func skipRepeats(_ f: @escaping @Sendable (A, A) -> Bool) async -> Event {
        return await self
            .withLast()
            .filter { pair in return pair.last.map { !f(pair.now, $0) } ?? false }
            .map(
                { first($0) }
            )
    }
}

extension Event where A: Equatable {
    public func skipRepeats() async -> Event {
        return await self
            .skipRepeats(
                { $0 == $1 }
            )
    }
}

public func sample<A: Sendable, B: Sendable>(on a: Event<A>) -> @Sendable (Event<@Sendable (A) -> B>) async -> Event<B> {
    return { a2b in
        let (event, push) = await Event<B>.create()
        let latest = AsyncValue<A>()
        await a.subscribe({ a in
            Task {
                await latest.set(a)
            }
        })
        let a: A? = await latest.wrapped
        await a2b.subscribe { a2b in
            if let a = a {
                await push(
                    a2b(a)
                )
            }
        }
        return event
    }
}

public func catOptionals<A: Sendable>(_ a: Event<A?>) async -> Event<A> {
    return await a
    |>
    mapOptional(
        { id($0) }
    )
}

public func mapOptional<A: Sendable, B: Sendable>(_ f: @escaping @Sendable (A) async -> B?) async -> @Sendable (Event<A>) async -> Event<B> {
    return { a in
        await a.mapOptional(
            f
        )
    }
}

// MARK: - Functor

extension Event {
    public func map<B: Sendable>(_ a2b: @escaping @Sendable (A) async -> B) async -> Event<B> {
        let event = await Event<B>()
        await self.subscribe(
            a2b
            >>>
            { await event.push($0) }
        )
        return event
    }

    public static func <¢> <B: Sendable>(a2b: @escaping @Sendable (A) async -> B, a: Event<A>) async -> Event<B> {
        return await a.map(a2b)
    }

    public static func <¢ <B: Sendable>(a: A, p: Event<B>) async -> Event {
        return await const(a) <¢> p
    }

    public static func ¢> <B: Sendable>(p: Event<B>, a: A) async -> Event {
        return await const(a) <¢> p
    }
}

public func map <A: Sendable, B: Sendable>(_ a2b: @escaping @Sendable (A) async -> B) async -> @Sendable (Event<A>) async -> Event<B> {
    return await curry(
            { await $0 <¢> $1 } // await a.map(a2b)
        )
        <| // await f(a)
        a2b
}

// MARK: - Apply

extension Event {
    public func apply<B: Sendable>(_ a2b: Event<@Sendable (A) async -> B>) async -> Event<B> {
        let (event, push) = await Event<B>.create()
        
        if let a2bLatest = await a2b.latest?.wrapped { //?? {@Sendable _ async in nil }
            await self.subscribe( 
                { a in
                    let b = await a2bLatest(a) //{
                    await push(b)
                    //}
                }
            )
        }
        if let selfLatest = await self.latest?.wrapped {
            await a2b.subscribe( 
                { a2b in
                    await push(
                        a2b(
                            selfLatest
                        )
                    )
                } 
            )
        }
        return event
    }

    public static func <*> <B: Sendable>(a2b: Event<@Sendable (A) async -> B>, a: Event<A>) async -> Event<B> {
        return await a.apply(a2b)
    }
}

public func apply<A: Sendable, B: Sendable>(_ a2b: Event<@Sendable (A) async -> B>) async -> @Sendable (Event<A>) async -> Event<B> {
    return await curry(
            { await $0 <*> $1 }
        )
        <|
        a2b
}

// MARK: - Applicative

public func pure<A: Sendable>(_ a: A) async -> Event<A> {
    let (event, push) = await Event<A>.create()
    await push(a)
    return event
}

// MARK: - Alt

extension Event: AsyncAlt {
    public static func <|> (lhs: Event, rhs: @autoclosure @escaping () async -> Event) async -> Event {
        return await .merge(lhs, rhs())
    }
}

// MARK: - Semigroup

extension Event: AsyncSemigroup where A: AsyncSemigroup {
    public static func <> (lhs: Event, rhs: Event) async -> Event {
//        return await curry(
//                { await $0 <> $1 }
//            )
//            <¢> //Event: await a.map(a2b)
        return await rhs.apply(
            await lhs.map(
                //await // curry(
                { @Sendable (a: A) async -> @Sendable (A) async -> A in
                    { @Sendable (b: A) async  -> A in
                        await a <> b
                    }
                }
                    //{ await $0 <> $1 }
                //)
            )
        )
//            <*>
//            rhs
    }
}

// MARK: - Monoid

extension Event: AsyncMonoid where A: AsyncMonoid {
    public static func empty() async -> Event {
        let a = await A.empty()
        return await pure(a)
    }

    public func concat() async -> Event {
        let a = await A.empty()
        return await self.reduce(a) { await $0 <> $1 }
    }
}
