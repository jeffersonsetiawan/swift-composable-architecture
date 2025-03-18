extension Optional: Reducer2 where Wrapped: Reducer2 {
  @inlinable
  public func reduce(
    into state: inout Wrapped.State, action: Wrapped.Action
  ) -> Effect2<Wrapped.Action> {
    switch self {
    case let .some(wrapped):
      return wrapped.reduce(into: &state, action: action)
    case .none:
      return .none
    }
  }
}
