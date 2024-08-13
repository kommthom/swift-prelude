import Foundation

extension KeyPath: @unchecked Sendable {}

public func get<Root: Sendable, Value: Sendable>(_ keyPath: KeyPath<Root, Value>) -> @Sendable (Root) -> Value {
    return { root in
        root[keyPath: keyPath]
    }
}

public func over<Root: Sendable, Value: Sendable>(_ keyPath: WritableKeyPath<Root, Value>) -> @Sendable (@escaping @Sendable (Value) -> Value) -> @Sendable (Root) -> Root {
    return { @Sendable over in { root in
        var copy = root
        copy[keyPath: keyPath] = over(copy[keyPath: keyPath])
        return copy
    } }
}

public func set<Root: Sendable, Value: Sendable>(_ keyPath: WritableKeyPath<Root, Value>) -> @Sendable (Value) -> @Sendable (Root) -> Root {
    return over(keyPath)
        <<<
        { const($0) }
}

prefix operator ^

extension KeyPath {
    public static prefix func ^ (rhs: KeyPath) -> @Sendable (Root) -> Value where Root: Sendable, Value: Sendable {
        return get(rhs)
    }
}
