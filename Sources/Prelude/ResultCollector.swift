//
//  ResultActor.swift
//
//
//  Created by Thomas Benninghaus on 30.07.24.
//

import Foundation

public actor ResultActor<A> {
    public var result: A?
    
    public init(_ result: A? = nil) {
        self.result = result
    }
    
    public func setResult(_ result: A) -> Void {
        self.result = result
    }
    
    public func setResultOfIndex(_ resultValue: A.Element?, idx: A.Index) -> Void where A: Sequence {
        //if self.isEmpty { self.result = [A.Element?] }
        self.result [idx] = resultValue
    }
    
    public var isEmpty: Bool {
        guard let _ = result else { return true }
        return false
    }
}
