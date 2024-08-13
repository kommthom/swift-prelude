public struct Unit: Codable, Sendable {}

public let unit = Unit()

extension Unit: Monoid {
    public static let empty: Unit = unit
  
    public static func <> (lhs: Unit, rhs: Unit) -> Unit {
        return unit
    }
}

extension Unit: Error {}
