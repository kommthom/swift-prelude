//
//  ResultCollector.swift
//
//
//  Created by Thomas Benninghaus on 30.07.24.
//

import Foundation

public actor ResultCollector<A> {
    public var result: A?
    
    public init(_ result: A? = nil) {
        self.result = result
    }
    
    public func setResult(_ result: A) -> Void {
        self.result = result
    }

    public var isEmpty: Bool {
        guard let _ = result else { return true }
        return false
    }
}

public actor ResultsCollector<A> {
    public var results: [A?]
    public var count: Int
    public init(_ results: [A?] = .init()) {
        self.results = results
        self.count = results.compactMap { $0 }.count
    }
    
    public func setResult(_ result: A?, idx: Int) -> Void {
        if idx == -1 { // at the end
            self.results.append(result)
        } else {
            self.results[idx] = result
        }
        self.count += 1
    }

    public var isEmpty: Bool {
        guard count == 0 else { return false }
        return true
    }
}
