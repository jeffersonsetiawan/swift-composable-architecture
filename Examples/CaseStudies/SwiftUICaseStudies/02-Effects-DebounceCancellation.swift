//
//  02-Effects-DebounceCancellation.swift
//  SwiftUICaseStudies
//
//  Created by Jefferson Setiawan on 11/09/20.
//  Copyright © 2020 Point-Free. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct DebounceState: Equatable {
    var text = ""
    var result = ""
}

enum DebounceAction: Equatable {
    case changeText(String)
    case checkText
    case receiveCheckText(String)
}

struct DebounceEnvironment {
    internal var mainQueue: AnySchedulerOf<DispatchQueue>
    internal var checkText: (String) -> Effect<String, Never>
}

let debounceReducer = Reducer<DebounceState, DebounceAction, DebounceEnvironment> { state, action, env in

    struct DebounceCancellationId: Hashable {}
    struct RequestCancellationId: Hashable {}

    switch action {
    case let .changeText(text):
        state.text = text
        if state.text == "" {
            return .merge(
                .cancel(id: DebounceCancellationId()),
                .cancel(id: RequestCancellationId())
            )
        }
        return .merge(
            .cancel(id: RequestCancellationId()),
            Effect(value: .checkText)
                .debounce(id: DebounceCancellationId(), for: 1, scheduler: env.mainQueue)
        )
    case .checkText:
        return env.checkText(state.text)
            .map(DebounceAction.receiveCheckText)
            .cancellable(id: RequestCancellationId(), cancelInFlight: true)
    case let .receiveCheckText(result):
        state.result = result
        return .none
    }
}

struct DebounceView: View {
    let store: Store<DebounceState, DebounceAction>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                Spacer()
                TextField(
                    "Type here",
                    text: viewStore.binding(
                        get: \.text,
                        send: DebounceAction.changeText
                    )
                )
                .disableAutocorrection(true)
                Text(viewStore.result)
                Spacer()
            }
            .padding()
        }
    }
}
