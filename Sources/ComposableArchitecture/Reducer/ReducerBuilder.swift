/// A result builder for combining reducers into a single reducer by running each, one after the
/// other, and merging their effects.
///
/// It is most common to encounter a reducer builder context when conforming a type to ``Reducer``
/// and implementing its ``Reducer/body-swift.property`` property.
///
/// See ``CombineReducers`` for an entry point into a reducer builder context.
@resultBuilder
public enum ReducerBuilder<State, Action> {
  @inlinable
  public static func buildArray(
    _ reducers: [some Reducer2<State, Action>]
  ) -> some Reducer2<State, Action> {
    _SequenceMany(reducers: reducers)
  }

  @inlinable
  public static func buildBlock() -> some Reducer2<State, Action> {
    EmptyReducer()
  }

  @inlinable
  public static func buildBlock<R: Reducer2<State, Action>>(_ reducer: R) -> R {
    reducer
  }

  @inlinable
  public static func buildEither<R0: Reducer2<State, Action>, R1: Reducer2<State, Action>>(
    first reducer: R0
  ) -> _Conditional<R0, R1> {
    .first(reducer)
  }

  @inlinable
  public static func buildEither<R0: Reducer2<State, Action>, R1: Reducer2<State, Action>>(
    second reducer: R1
  ) -> _Conditional<R0, R1> {
    .second(reducer)
  }

  @inlinable
  public static func buildExpression<R: Reducer2<State, Action>>(_ expression: R) -> R {
    expression
  }

  @inlinable
  @_disfavoredOverload
  public static func buildExpression(
    _ expression: any Reducer2<State, Action>
  ) -> Reduce<State, Action> {
    Reduce(expression)
  }

  @inlinable
  public static func buildFinalResult<R: Reducer2<State, Action>>(_ reducer: R) -> R {
    reducer
  }

  @inlinable
  public static func buildLimitedAvailability(
    _ wrapped: some Reducer2<State, Action>
  ) -> Reduce<State, Action> {
    Reduce(wrapped)
  }

  @inlinable
  public static func buildOptional<R: Reducer2<State, Action>>(_ wrapped: R?) -> R? {
    wrapped
  }

  @inlinable
  public static func buildPartialBlock<R: Reducer2<State, Action>>(first: R) -> R {
    first
  }

  @inlinable
  public static func buildPartialBlock<R0: Reducer2<State, Action>, R1: Reducer2<State, Action>>(
    accumulated: R0, next: R1
  ) -> _Sequence<R0, R1> {
    _Sequence(accumulated, next)
  }

  public enum _Conditional<First: Reducer2, Second: Reducer2<First.State, First.Action>>: Reducer2 {
    case first(First)
    case second(Second)

    @inlinable
    public func reduce(into state: inout First.State, action: First.Action) -> Effect2<
      First.Action
    > {
      switch self {
      case let .first(first):
        return first.reduce(into: &state, action: action)

      case let .second(second):
        return second.reduce(into: &state, action: action)
      }
    }
  }

  public struct _Sequence<R0: Reducer2, R1: Reducer2<R0.State, R0.Action>>: Reducer2 {
    @usableFromInline
    let r0: R0

    @usableFromInline
    let r1: R1

    @usableFromInline
    init(_ r0: R0, _ r1: R1) {
      self.r0 = r0
      self.r1 = r1
    }

    @inlinable
    public func reduce(into state: inout R0.State, action: R0.Action) -> Effect2<R0.Action> {
      self.r0.reduce(into: &state, action: action)
        .merge(with: self.r1.reduce(into: &state, action: action))
    }
  }

  public struct _SequenceMany<Element: Reducer2>: Reducer2 {
    @usableFromInline
    let reducers: [Element]

    @usableFromInline
    init(reducers: [Element]) {
      self.reducers = reducers
    }

    @inlinable
    public func reduce(
      into state: inout Element.State, action: Element.Action
    ) -> Effect2<Element.Action> {
      self.reducers.reduce(.none) { $0.merge(with: $1.reduce(into: &state, action: action)) }
    }
  }
}
