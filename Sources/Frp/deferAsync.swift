//
//  File.swift
//  
//
//  Created by Thomas Benninghaus on 01.08.24.
//

import Foundation

public func deferAsync(_ perform: @escaping @Sendable () async -> Void) async {
    // suspends until cancelled
    for await _ in AsyncStream<Never>.makeStream().stream {}
    await Task { await perform() }.value
}

@discardableResult
func run<T>(_ operation: () async throws -> T, defer deferredOperation: () async throws -> Void) async throws -> T {
    do {
        let result = try await operation()
        try await deferredOperation()
        return result
    } catch {
        try await deferredOperation()
        throw error
    }
}
/* Usage:
try await run {
print("doing")
try await Task.sleep(for: .seconds(1))
print("done")
} defer: {
try await Task.sleep(for: .milliseconds(100))
print("cleanup done")
}
*/
