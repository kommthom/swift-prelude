import Prelude

public struct Writer<W: Monoid, A: Sendable> {
    let a: A
    let w: W

    public init(_ a: A, _ w: W) {
        self.a = a
        self.w = w
    }

    public var runWriter: (A, W) {
        return (a, w)
    }
}

// MARK: - Functor

extension Writer {
    public func map<B: Sendable>(_ f: @Sendable (A) -> B) -> Writer<W, B> {
        return .init(f(self.a), self.w)
    }

    public static func <¢> <WW: Sendable, AA: Sendable, B: Sendable> (f: @escaping @Sendable (AA) -> B, writer: Writer<WW, AA>) -> Writer<WW, B> {
        return writer.map(f)
    }
}

// MARK: - Apply

extension Writer {
    public func apply<B: Sendable>(_ f: Writer<W, @Sendable (A) -> B>) -> Writer<W, B> {
        return .init(f.a(self.a), self.w <> f.w)
    }

    public static func <*> <WW: Sendable, AA: Sendable, B: Sendable> (f: Writer<WW, @Sendable (AA) -> B>, writer: Writer<WW, AA>) -> Writer<WW, B> {
        return writer.apply(f)
    }
}

// MARK: - Applicative

public func pure<W, A: Sendable>(_ a: A) -> Writer<W, A> {
    return .init(a, W.empty)
}

// MARK: - Monad

extension Writer {
    public func flatMap<B: Sendable>(_ f: @Sendable (A) -> Writer<W, B>) -> Writer<W, B> {
        let writer = f(self.a)
        return .init(writer.a, self.w <> writer.w)
    }
}
