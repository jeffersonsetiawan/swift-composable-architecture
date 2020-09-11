//
//  02-Effects-Debounce-CancellationTests.swift
//  SwiftUICaseStudiesTests
//
//  Created by Jefferson Setiawan on 11/09/20.
//  Copyright © 2020 Point-Free. All rights reserved.
//

import Combine
import ComposableArchitecture
import XCTest

@testable import SwiftUICaseStudies

class DebounceEffectsTests: XCTestCase {
    let scheduler = DispatchQueue.testScheduler
    func testReducer() {
        let store = TestStore(
            initialState: .init(),
            reducer: debounceReducer,
            environment: .init(
                mainQueue: self.scheduler.eraseToAnyScheduler(),
                checkText: { _ in
                    Effect(value: "Success")
                        .delay(for: 0.5, scheduler: self.scheduler)
                    .eraseToEffect()
                }
            )
        )
        
        store.assert(
            .send(.changeText("asd")) {
                $0.text = "asd"
            },
            .do {
                self.scheduler.advance(by: 0.9)
            },
            .send(.changeText("toko")) {
                $0.text = "toko"
            },
            .do {
                self.scheduler.advance(by: 0.1)
            },
            .do {
                self.scheduler.advance(by: 0.9)
            },
            .receive(.checkText),
            .do {
                self.scheduler.advance(by: 0.5)
            },
            .receive(.receiveCheckText("Success")) {
                $0.result = "Success"
            }
        )
    }
    
    func testCancelRequest() {
        let store = TestStore(
            initialState: .init(),
            reducer: debounceReducer,
            environment: .init(
                mainQueue: self.scheduler.eraseToAnyScheduler(),
                checkText: { _ in
                    Effect(value: "Success")
                        .delay(for: 0.5, scheduler: self.scheduler)
                    .eraseToEffect()
                }
            )
        )
        
        store.assert(
            .send(.changeText("toko")) {
                $0.text = "toko"
            },
            .do {
                self.scheduler.advance(by: 0.1)
            },
            .do {
                self.scheduler.advance(by: 0.9)
            },
            .receive(.checkText),
            .do {
                self.scheduler.advance(by: 0.4)
            },
            .send(.changeText("")) {
                $0.text = ""
            }
        )
    }
}
