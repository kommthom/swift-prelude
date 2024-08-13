//
//  SendableExtensions.swift
//  swift-prelude
//
//  Created by Thomas Benninghaus on 05.08.24.
//

import Foundation

extension Array: Sendable where Element == Sendable {}

//extension Set: Sendable {}
