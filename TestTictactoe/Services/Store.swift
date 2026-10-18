//
//  Store.swift
//  TestTictactoe
//

import Observation

/// A reducer mutates state in response to an action. It must be pure.
typealias Reducer<State, Action> = (inout State, Action) -> Void

/// A minimal Redux-style store: a single source of truth that changes only by dispatching actions.
@Observable
final class Store<State, Action> {
    private(set) var state: State
    @ObservationIgnored private let reducer: Reducer<State, Action>

    init(initialState: State, reducer: @escaping Reducer<State, Action>) {
        self.state = initialState
        self.reducer = reducer
    }

    func send(_ action: Action) {
        reducer(&state, action)
    }
}
