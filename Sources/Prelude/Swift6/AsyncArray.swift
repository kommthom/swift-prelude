//
//  AsyncArray.swift
//
//
//  Created by Thomas Benninghaus on 07.08.24.
//

import Foundation

public actor AsyncArray<A: Sendable>: AsyncMonoid {
    public var wrapped: [A]?
    public var count: Int { wrapped?.count ?? 0 }
    
    public static func empty() async -> Self {
        .init()
    }
    
    public static func <> (lhs: AsyncArray<A>, rhs: AsyncArray<A>) async -> AsyncArray<A> {
        guard let lhsUnwrapped = await lhs.wrapped else { return rhs }
        guard let rhsUnwrapped = await rhs.wrapped else { return lhs }
        return .init(lhsUnwrapped + rhsUnwrapped)
    }
    
    public init(_ wrapped: [A]? = .init()) {
        self.wrapped = wrapped
    }
    
    public func set(_ value: A, idx: Int = -1) {
        guard let _ = wrapped else { wrapped = [value]; return }
        if idx == -1 || idx >= count { // at the end
            self.wrapped?.append(value)
        } else {
            self.wrapped![idx] = value
        }
    }
    
    public func append(_ value: A) { set(value) }

    public func asyncMap<B: Sendable>(_ transform: (A) async -> B) async -> [B] {
        var values = [B]()
        if let unwrapped = wrapped {
            for element in unwrapped {
                await values.append(transform(element))
            }
        }
        return values
    }

    public func asyncForEach(_ operation: @Sendable (A) async -> Void) async {
        if let unwrapped = wrapped {
            for element in unwrapped {
                await operation(element)
            }
        }
    }
    
    public var isEmpty: Bool {
        guard count == 0 else { return false }
        return true
    }
}
