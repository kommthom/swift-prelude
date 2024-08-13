public protocol Plus: Alt {
    static var empty: Self { get }
}

extension Array: Plus {
  public static var empty: Array<Element> {
    .init()
  }
}

extension Optional: Plus {
    public static var empty: Optional {
        return .none
    }
}
