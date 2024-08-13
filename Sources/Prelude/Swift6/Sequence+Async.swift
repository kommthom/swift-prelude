//
//  Sequence+Async.swift
//
//
//  Created by Thomas Benninghaus on 06.08.24.
//

import Foundation

extension Sequence where Element: Sendable {
    public func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }
        return values
    }
}

extension Sequence where Element: Sendable {
    public func asyncForEach(_ operation: @Sendable (Element) async throws -> Void) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}

extension Sequence where Element: Sendable {
    public func concurrentForEach(_ operation: @escaping @Sendable (Element) async -> Void) async {
        // A task group automatically waits for all of its
        // sub-tasks to complete, while also performing those
        // tasks in parallel:
        await withTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask {
                    await operation(element)
                }
            }
        }
    }
}
