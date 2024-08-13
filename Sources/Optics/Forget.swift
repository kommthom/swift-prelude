public struct Forget<R: Sendable, A: Sendable, B: Sendable>: Sendable {
    public let unwrap: @Sendable (A) -> R

    public init(_ unwrap: @escaping @Sendable (A) -> R) {
        self.unwrap = unwrap
    }
}
