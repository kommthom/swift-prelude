//
//  AsyncValue.swift
//
//
//  Created by Thomas Benninghaus on 07.08.24.
//

import Foundation

public protocol AsyncSemigroup: Sendable {
    static func <> (lhs: Self, rhs: Self) async -> Self
}

public protocol AsyncMonoid: AsyncSemigroup {
    static func empty() async -> Self
}

public protocol AsyncAlt {
    static func <|>(lhs: Self, rhs: @autoclosure @escaping @Sendable () async -> Self) async -> Self
}

public actor AsyncValue<A: Sendable>: Sendable {
    public static func empty() async -> AsyncValue<A> {
        .init()
    }
    /*
    public static func <> (lhs: AsyncValue<A>, rhs: AsyncValue<A>) async -> AsyncValue<A> {
        guard let lhsUnwrapped = await lhs.wrapped else { return rhs }
        guard let rhsUnwrapped = await rhs.wrapped else { return lhs }
        return await .init(lhsUnwrapped <> rhsUnwrapped)
    }
    */
    public var wrapped: A?
    
    public init(_ wrapped: A? = nil) {
        self.wrapped = wrapped
    }
    
    public func set(_ wrapped: A) {
        self.wrapped = wrapped
    }

    public func asyncMap(_ transform: (A) async -> Void) async -> Void {
        if let unwrapped = wrapped {
            await transform(unwrapped)
        }
    }
    
    public var isEmpty: Bool {
        guard let _ = wrapped else { return true }
        return false
    }
}

extension String: AsyncSemigroup, AsyncMonoid {
    public static func empty() async -> String {
        ""
    }
    
}

extension Array: AsyncSemigroup where Element == String {
    public static func <> (lhs: Array<Element>, rhs: Array<Element>) async -> Array<Element> {
        lhs + rhs
    }
}

extension Array: AsyncMonoid where Element == String {
    public static func empty() async -> Array<Element> {
        self.init()
    }
}
