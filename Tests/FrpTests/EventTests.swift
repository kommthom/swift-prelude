import Frp
import Prelude
import ValidationSemigroup
import XCTest

public final class TestSubscription<A: Sendable> {
    fileprivate var history: AsyncArray<A> = .init()
}

public func subscribe<A: Sendable>(to event: Event<A>) async -> TestSubscription<A> {
    let sub = TestSubscription<A>()
    await event.subscribe { await sub.history.append($0) }
    return sub
}

final class EventTests: XCTestCase {
    func testCombine() async {
        let (xs, pushx) = await Event<Int>.create()
        let (ys, pushy) = await Event<String>.create()

        let combined = await subscribe(to: Event.combine(xs, ys))

        await pushx(1)
        var result = await combined.history.wrapped
        XCTAssertEqual([], result!.map { $0.0 })
        XCTAssertEqual([], result!.map { $0.1 })

        await pushy("a")
        result = await combined.history.wrapped
        XCTAssertEqual([1], result!.map { $0.0 })
        XCTAssertEqual(["a"], result!.map { $0.1 })

        await pushx(3)
        result = await combined.history.wrapped
        XCTAssertEqual([1, 3], result!.map { $0.0 })
        XCTAssertEqual(["a", "a"], result!.map { $0.1 })
    }

    func testMerge() async {
        let (xs, pushx) = await Event<Int>.create()
        let (ys, pushy) = await Event<Int>.create()
        let (zs, pushz) = await Event<Int>.create()

        let merged = await subscribe(to: xs <|> ys <|> zs)

        await pushx(6)
        var resultx = await merged.history.wrapped
        XCTAssertEqual([6], resultx)

        await pushy(28)
        resultx = await merged.history.wrapped
        XCTAssertEqual([6, 28], resultx)

        await pushz(496)
        resultx = await merged.history.wrapped
        XCTAssertEqual([6, 28, 496], resultx)
    }

    func testFilter() async {
        let (xs, push) = await Event<Int>.create()

        let evens = await subscribe(to: xs.filter { $0 % 2 == 0 })

        await push(1)
        var resultx = await evens.history.wrapped
        XCTAssertEqual([], resultx)

        await push(2)
        resultx = await evens.history.wrapped
        XCTAssertEqual([2], resultx)

        await push(3)
        resultx = await evens.history.wrapped
        XCTAssertEqual([2], resultx)
    }

    func testReduce() async {
        let (xs, multiplyBy) = await Event<Int>.create()

        let values = await subscribe(to: xs.reduce(1) { $0 * $1 })

        await multiplyBy(2)
        var resultx = await values.history.wrapped
        XCTAssertEqual([2], resultx)

        await multiplyBy(2)
        resultx = await values.history.wrapped
        XCTAssertEqual([2, 4], resultx)

        await multiplyBy(2)
        resultx = await values.history.wrapped
        XCTAssertEqual([2, 4, 8], resultx)
    }

    func testCount() async {
        let (xs, push) = await Event<()>.create()

        let count = await subscribe(to: xs.count())

        await push(())
        var resultx = await count.history.wrapped
        XCTAssertEqual([1], resultx)

        await push(())
        resultx = await count.history.wrapped
        XCTAssertEqual([1, 2], resultx)

        await push(())
        resultx = await count.history.wrapped
        XCTAssertEqual([1, 2, 3], resultx)
    }

    func testWithLast() async {
        let (xs, push) = await Event<Int>.create()

        let count = await subscribe(to: xs.withLast())

        await push(1)
        var resultx = await count.history.wrapped!.asyncMap { $0.0 }
        var resulty = await count.history.wrapped!.asyncMap { $0.1 }
        XCTAssertEqual([1], resultx)
        XCTAssertEqual([nil], resulty)

        await push(2)
        resultx = await count.history.wrapped!.asyncMap { $0.0 }
        resulty = await count.history.wrapped!.asyncMap { $0.1 }
        XCTAssertEqual([1, 2], resultx)
        XCTAssertEqual([nil, .some(1)], resulty)

        await push(3)
        resultx = await count.history.wrapped!.asyncMap { $0.0 }
        resulty = await count.history.wrapped!.asyncMap { $0.1 }
        XCTAssertEqual([1, 2, 3], resultx)
        XCTAssertEqual([nil, .some(1), .some(2)], resulty)
    }

    func testSampleOn() async {
        let (xs, pushx) = await Event<()>.create()
        let (ys, pushy) = await Event<Int>.create()

        let samples = await subscribe(to: ys.sample(on: xs))

        await pushx(())
        var resultx = await samples.history.wrapped
        XCTAssertEqual([], resultx)

        await pushy(1)
        resultx = await samples.history.wrapped
        XCTAssertEqual([], resultx)

        await pushx(())
        resultx = await samples.history.wrapped
        XCTAssertEqual([1], resultx)

        await pushy(2)
        resultx = await samples.history.wrapped
        XCTAssertEqual([1], resultx)

        await pushx(())
        resultx = await samples.history.wrapped
        XCTAssertEqual([1, 2], resultx)
    }

    func testMapOptional() async {
        let (xs, push) = await Event<Int>.create()

        let mapped = await subscribe(to: xs.mapOptional { $0 % 2 == 0 ? String($0) : nil })

        await push(1)
        var resultx = await mapped.history.wrapped
        XCTAssertEqual([], resultx)

        await push(2)
        resultx = await mapped.history.wrapped
        XCTAssertEqual(["2"], resultx)

        await push(3)
        resultx = await mapped.history.wrapped
        XCTAssertEqual(["2"], resultx)
      }

    func testCatOptionals() async {
        let (xs, push) = await Event<Int?>.create()

        let catted = await subscribe(to: catOptionals(xs))

        await push(nil)
        var resultx = await catted.history.wrapped
        XCTAssertEqual([], resultx)

        await push(1)
        resultx = await catted.history.wrapped
        XCTAssertEqual([1], resultx)

        await push(nil)
        resultx = await catted.history.wrapped
        XCTAssertEqual([1], resultx)
    }

    func testMap() async {
        let (strings, push) = await Event<String>.create()

        let uppercased = await subscribe(to: strings.map { $0.uppercased() })

        await push("blob")
        let resultx = await uppercased.history.wrapped
        XCTAssertEqual(["BLOB"], resultx)
    }

    func testApply() async {
        let (xs, push) = await Event<Int>.create()

        let incrs = await subscribe(to:
            pure
            { @Sendable a in a + 1 }
            <*>
            xs
        )

        await push(0)
        var resultx = await incrs.history.wrapped
        XCTAssertEqual([1], resultx)

        await push(99)
        resultx = await incrs.history.wrapped
        XCTAssertEqual([1, 100], resultx)
    }

    func testAppend() async {
        let (greeting, pushGreeting) = await Event<String>.create()
        let (name, pushName) = await Event<String>.create()
        let event = await
            greeting
            <>
            pure(", ")
            <>
            name
            <>
            pure("!")
        let appends = await subscribe(to: event)

        await pushGreeting("Hello")
        var result = await appends.history.wrapped
        XCTAssertEqual([], result)

        await pushName("Blob")
        result = await appends.history.wrapped
        XCTAssertEqual(["Hello, Blob!"], result)

        await pushGreeting("Goodbye")
        result = await appends.history.wrapped
        XCTAssertEqual(["Hello, Blob!", "Goodbye, Blob!"], result)
    }

    func testConcat() async {
        let (lines, push) = await Event<[String]>.create()

        let concatted = await subscribe(to: 
            lines
                .concat())

        await push(["hello"])
        var result = await concatted.history.wrapped
        XCTAssertEqual([["hello"]], result)
        
        await push(["and", "goodbye"])
        result = await concatted.history.wrapped
        XCTAssertEqual([["hello"], ["hello", "and", "goodbye"]], result)
    }
}
