import ComposableArchitecture
import SwiftUI

@main
struct CaseStudiesApp: App {
  var body: some Scene {
    WindowGroup {
      RootView()
    }
  }
}

typealias Store = Store2
typealias Reducer = Reducer2
typealias ReducerOf<R: Reducer2> = Reducer2Of<R>
