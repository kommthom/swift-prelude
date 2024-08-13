import Prelude

public struct Reader<R: Sendable, A: Sendable>: Sendable {
    public let runReader: @Sendable (R) -> A

    public init(_ runReader: @escaping @Sendable (R) -> A) {
        self.runReader = runReader
    }
}

// MARK: - Functor

extension Reader {
    public func map<B: Sendable>(_ f: @escaping @Sendable (A) -> B) -> Reader<R, B> {
        return .init(
            self.runReader
            >>>
            f
        )
    }

    public static func <¢> <RR: Sendable, B: Sendable, C: Sendable> (f: @escaping @Sendable (B) -> C, reader: Reader<RR, B>) -> Reader<RR, C> {
        return reader.map(f)
    }
}

// MARK: - Apply

extension Reader {
    public func apply<B: Sendable>(_ f: Reader<R, @Sendable (A) -> B>) -> Reader<R, B> where R: Sendable {
        return .init { r in
            f.runReader(r) 
            <|
            self.runReader(r)
        }
  }

  public static func <*> <RR: Sendable, B: Sendable, C: Sendable> (f: Reader<RR, @Sendable (B) -> C>, reader: Reader<RR, B>) -> Reader<RR, C> {
      return reader.apply(f)
  }
}

// MARK: - Applicative

public func pure<R: Sendable, A: Sendable>(_ a: A) -> Reader<R, A> {
    return .init(const(a))
}

// MARK: - Monad

extension Reader {

    public func flatMap<B: Sendable>(_ f: @escaping @Sendable (A) -> Reader<R, B>) -> Reader<R, B> where R: Sendable {
        return .init { r in
            f(
                self
                    .runReader(r)
            )
            .runReader(r)
        }
    }
}
